require 'basiccache'
require 'set'

module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo < Base
    def initialize(params = {})
      super
    end

    def build_packages(paths, makepkg_flags = '')
      paths.each do |path|
        dir = File.dirname(path)
        puts "Building #{File.basename(dir)}"
        Dir.chdir(dir) { run "makepkg #{makepkg_flags}" }
      end
    end

    def add_packages(paths)
      paths.each do |path|
        key = File.basename(path)
        sig_key, sig_path = [key, path].map { |x| x + '.sig' }
        next if include? key
        client.upload!(sig_key, sig_path) if ENV['S3REPO_SIGN_PACKAGES']
        client.upload!(key, path)
      end
      metadata.add_packages(paths)
    end

    def remove_packages(packages)
      metadata.remove_packages(packages)
    end

    def prune_packages
      if orphans.empty?
        puts 'No orphaned packages'
        return
      end
      puts "Pruning packages: #{orphans.join(', ')}"
      client.delete_objects(delete: { objects: orphans.map { |x| { key: x } } })
    end

    def packages
      package_cache.cache { parse_packages }
    end

    def include?(key)
      !packages.find { |x| x.key == key }.nil?
    end

    def serve(key)
      refresh = !key.match(/\.pkg\.tar\.xz$/)
      file_cache.serve(key, refresh)
    end

    private

    def orphans
      packages.map(&:key).reject do |x|
        metadata.packages.include? x.reverse.split('-', 2).last.reverse
      end
    end

    def metadata
      @metadata ||= Metadata.new(client: client, file_cache: file_cache)
    end

    def package_cache
      @package_cache ||= BasicCache::TimeCache.new lifetime: 60
    end

    def parse_packages
      client.list_objects(bucket: bucket).contents.select do |x|
        x.key.match(/.*\.pkg\.tar\.xz$/)
      end
    end
  end
end
