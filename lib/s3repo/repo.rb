require 'basiccache'

module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo < Base
    def initialize(params = {})
      super
    end

    def add_packages(paths)
      paths.each do |path|
        key = File.basename(path)
        next if include? key
        client.upload!(key, path)
      end
      metadata.add_packages(path)
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

    def file_cache
      @file_cache ||= Cache.new(client: client, tmpdir: @options[:tmpdir])
    end

    def package_cache
      @package_cache ||= BasicCache::TimeCache.new lifetime: 600
    end

    def parse_packages
      client.list_objects(bucket: bucket).contents.select do |x|
        x.key.match(/.*\.pkg\.tar\.xz$/)
      end
    end
  end
end
