module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo < Base
    def add_package(file)
      upload!(file)
      package = Package.new(client: client, name: file)
      metadata.add_package(package)
      package
    end

    def packages
      @packages = parse_packages
    end

    def metadata
      @metadata ||= Metadata.new(client: client)
    end

    private

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
      resp.map { |x| Package.new(client: client, name: x) }
    end
  end
end
