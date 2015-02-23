module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo
    def initialize(params = {})
      @options = params
      fail('No bucket given') unless bucket
    end

    def add_package(file)
      upload!(file)
      package = Package.new(client: client, name: file)
      metadata.add_package(package)
      package
    end

    def packages(nocache = false)
      @packages = nil if nocache
      @packages ||= parse_packages
    end

    def metadata
      @metadata ||= Metadata.new(client: client)
    end

    private

    def parse_packages
      resp = client.list_objects(bucket: bucket).contents.map(&:key)
      resp.select! { |x| x.match(/.*\.pkg\.tar\.xz$/) }
      resp.map { |x| Package.new(client: client, name: x) }
    end

    def bucket
      @bucket ||= @options[:bucket] || ENV['S3_BUCKET']
    end

    def client
      @client ||= S3Repo.aws_client
    end
  end
end
