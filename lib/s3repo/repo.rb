require 'basiccache'

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
        next if include? key
        client.upload!(key, path)
      end
      metadata.add_packages(paths)
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
