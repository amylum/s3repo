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

    def targets
      @targets ||= @options[:targets] || ['x86_64']
    end

    def bucket
      @options[:bucket] || raise('No bucket given')
    end

    def client
      @options[:client] ||= Client.new(@options)
    end

    def file_cache
      @file_cache ||= @options[:file_cache] || Cache.new(@options)
    end
  end
end
