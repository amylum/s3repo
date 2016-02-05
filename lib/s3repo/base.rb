require 'English'

module S3Repo
  ##
  # Base object, used to provide common attributes
  class Base
    def initialize(params = {})
      @options = params
    end

    private

    def run(cmd)
      results = `#{cmd} 2>&1`
      return results if $CHILD_STATUS.success?
      raise "Failed running #{cmd}:\n#{results}"
    end

    def bucket
      @bucket ||= @options[:bucket] || ENV['S3_BUCKET']
      return @bucket if @bucket
      raise('No bucket given')
    end

    def client
      @client ||= @options[:client] || Client.new(bucket: bucket)
    end

    def file_cache
      @file_cache ||= @options[:file_cache] || Cache.new(
        client: client, tmpdir: @options[:tmpdir]
      )
    end
  end
end
