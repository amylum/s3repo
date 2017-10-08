require 'basiccache'
require 'set'

module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo < Base
    def build_packages(paths)
      paths.each do |path|
        dir = File.dirname(path)
        puts "Building #{File.basename(dir)}"
        Dir.chdir(dir) { run "makepkg #{@options[:makepkg_flags]}" }
      end
    end

    def add_packages(paths)
      paths.select! { |path| upload_package(path) }
      metadata.add_packages(paths) unless paths.empty?
      templates.update! unless paths.empty?
    end

    def remove_packages(packages)
      metadata.remove_packages(packages)
      templates.update!
    end

    def prune_files
      if orphans.empty?
        puts 'No orphaned files'
        return
      end
      puts "Pruning files: #{orphans.join(', ')}"
      client.delete_objects(delete: { objects: orphans.map { |x| { key: x } } })
    end

    def packages
      package_cache.cache { parse_objects(/.*\.pkg\.tar\.xz$/) }
    end

    def signatures
      parse_objects(/.*\.pkg\.tar\.xz\.sig$/)
    end

    def include?(key)
      !packages.find { |x| x.key == key }.nil?
    end

    private

    def upload_package(path)
      key = File.basename(path)
      return false if include? key
      sig_path = signer.sign(path)
      sig_key = key + '.sig'
      client.upload_file(sig_key, sig_path) if @options[:sign_packages]
      client.upload_file(key, path)
      true
    end

    def orphans
      (packages + signatures).map(&:key).reject do |x|
        metadata.packages.include? x.reverse.split('-', 2).last.reverse
      end
    end

    def metadata
      @options[:metadata] ||= Metadata.new(@options)
    end

    def signer
      @options[:signer] ||= Signer.new(@options)
    end

    def templates
      @templates ||= Templates.new(@options)
    end

    def package_cache
      @package_cache ||= BasicCache::TimeCache.new lifetime: 60
    end

    def parse_objects(regex)
      client.list_objects(bucket: bucket).contents.select { |x| x.key =~ regex }
    end
  end
end
