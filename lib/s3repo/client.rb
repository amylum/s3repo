require 'aws-sdk'

module S3Repo
  ##
  # AWS API client
  class Client
    def initialize(params = {})
      @api = Aws::S3::Client.new
      @defaults = params
    end

    def respond_to?(method, include_all = false)
      @api.respond_to?(method, include_all) || super
    end

    def upload!(key, path)
      puts "Uploading #{key}"
      put_object key: key, body: File.open(path) { |fh| fh.read }
    end

    def remove!(key)
      puts "Removing #{key}"
      delete_object key: key
    end

    private

    def method_missing(method, *args, &block)
      return super unless @api.respond_to?(method)
      define_singleton_method(method) do |*singleton_args|
        params = build_params(singleton_args)
        @api.send(method, params)
      end
      send(method, args.first)
    end

    def build_params(args)
      fail 'Too many arguments given' if args.size > 1
      params = args.first || {}
      fail 'Argument must be a hash' unless params.is_a? Hash
      @defaults.dup.merge!(params)
    end
  end
end
