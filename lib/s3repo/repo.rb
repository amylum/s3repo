module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo < Base
    def add_package(file)
      upload!(file)
      package = Package.new(client: client, key: file)
      metadata.add_package(package)
      package
    end

    def packages
      @packages ||= parse_packages
    end

    def serve(path, recheck = true)
      cache.serve(path, recheck)
    end

    def metadata
      @metadata ||= Metadata.new(client: client)
    end

    private

    def cache
      @cache ||= Cache.new(client: client, tmpdir: @options[:tmpdir])
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
