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

    private

    def method_missing(method, *args, &block)
      if @api.respond_to?(method) && args.size == 1 && args.first.is_a? Hash
        define_singleton_method(method) do |*a|
          @api.send(method, @defaults.dup.merge! args.first)
        end
        send(method, new_args)
      else
        super
      end
    end
  end
end
