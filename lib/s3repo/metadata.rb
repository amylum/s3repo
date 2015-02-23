module S3Repo
  ##
  # Metadata object, represents a package DB
  class Metadata
    def initialize(params = {})
      @options = params
    end

    private

    def client
      @client ||= @options[:client] || fail('No client attribute provided')
    end
  end
end
