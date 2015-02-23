module S3Repo
  ##
  # Base object, used to provide common attributes
  class Base
    def initialize(params = {})
      @options = params
      fail('No bucket given') unless bucket
    end

    private

    def bucket
      @bucket ||= @options[:bucket] || ENV['S3_BUCKET']
    end

    def client
      @client ||= @options[:client] || Client.new(bucket: bucket)
    end
  end
end
