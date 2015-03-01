require 'basiccache'

module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo < Base
    def initialize(params = {})
      super
    end

    def add_package(file)
      upload!(file)
      package = Package.new(client: client, key: file)
      metadata.add_package(package)
      package
    end

    def packages
      meta_cache.cache { parse_packages }
    end

    def serve(key)
      refresh = !key.match(/\.pkg\.tar\.xz$/)
      file_cache.serve(key, refresh)
    end

    def metadata
      @metadata ||= Metadata.new(client: client)
    end

    private

    def file_cache
      @file_cache ||= Cache.new(client: client, tmpdir: @options[:tmpdir])
    end

    def meta_cache
      @meta_cache ||= BasicCache::TimeCache.new lifetime: 600
    end

    def upload!(file)
      client.put_object(
        bucket: bucket,
        key: file,
        body: File.open(file) { |fh| fh.read }
      )
    end

    def parse_packages
      resp = client.list_objects(bucket: bucket).contents.map(&:key)
      resp.select! { |x| x.match(/.*\.pkg\.tar\.xz$/) }
      resp.map { |x| Package.new(client: client, key: x) }
    end
  end
end
