module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo
    def initialize(params = {})
      @options = params
    end

    def add_package(file)
      package = Package.new(client: client, file: file)
      package.upload!
      metadata.add_package(package)
    end

    def metadata
      @metadata ||= Metadata.new(client: client)
    end

    private

    def client
      @client ||= S3Repo.aws_client
    end
  end
end
