require 'aws-sdk'

module S3Repo
  class Repo
    def initialize
    end

    private

    def client
      @client ||= Aws::S3::Client.new
    end
  end
end
