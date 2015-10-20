if ENV['CI'] == 'true'
  require 'simplecov'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'rspec'
require 's3repo'

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.before_record do |i|
    i.request.headers.delete 'Authorization'
  end
end

require 'climate_control'
AUTH_OPTS = {
  S3_BUCKET: 'amylum',
  AWS_REGION: 'us-east-1',
  AWS_SECRET_ACCESS_KEY: 'accesskey',
  AWS_ACCESS_KEY_ID: 'sekritkey'
}
def with_auth(&block)
  opts = AUTH_OPTS.dup.map { |k, v| [k, ENV.fetch("REAL_#{k}", v)] }.to_h
  ClimateControl.modify(opts, &block)
end
