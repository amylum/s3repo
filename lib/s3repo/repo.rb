require 'aws-sdk'

module S3Repo
  ##
  # Repo object, represents an Arch repo inside an S3 bucket
  class Repo
    def initialize
    end

    private

    def client
      @client ||= Aws::S3::Client.new
    end
  end
end
