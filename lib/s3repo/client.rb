require 'aws-sdk'

module S3Repo
  ##
  # AWS API client
  class Client
    def initialize(params = {})
      @api = Aws::S3::Client.new
      @defaults = params
    end

    def respond_to_missing?(method, include_all = false)
      @api.respond_to?(method, include_all) || super
    end

    def upload(key, body)
      puts "Uploading #{key}"
      put_object key: key, body: body
    end

    def upload_file(key, path)
      upload(key, File.open(path).read)
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
      raise 'Too many arguments given' if args.size > 1
      params = args.first || {}
      raise 'Argument must be a hash' unless params.is_a? Hash
      @defaults.dup.merge!(params)
    end
  end
end
