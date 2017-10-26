require 'English'
$LOAD_PATH.unshift File.expand_path('../lib/', __FILE__)
require 's3repo/version'

Gem::Specification.new do |s|
  s.name        = 's3repo'
  s.version     = S3Repo::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.summary     = 'S3 Archlinux repo library'
  s.description = 'Simple library for interacting with Archlinux repos in S3'
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/amylum/s3repo'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split
  s.executables = ['s3repo']

  s.add_dependency 'aws-sdk', '~> 3.0.0'
  s.add_dependency 'basiccache', '~> 1.0.0'
  s.add_dependency 'cymbal', '~> 1.0.0'
  s.add_dependency 'mercenary', '~> 0.3.4'

  s.add_development_dependency 'climate_control', '~> 0.2.0'
  s.add_development_dependency 'codecov', '~> 0.1.1'
  s.add_development_dependency 'fuubar', '~> 2.2.0'
  s.add_development_dependency 'goodcop', '~> 0.1.0'
  s.add_development_dependency 'rake', '~> 12.2.1'
  s.add_development_dependency 'rspec', '~> 3.7.0'
  s.add_development_dependency 'rubocop', '~> 0.51.0'
  s.add_development_dependency 'vcr', '~> 3.0.0'
  s.add_development_dependency 'webmock', '~> 3.1.0'
end
