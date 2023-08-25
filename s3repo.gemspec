require 'English'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)
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

  s.add_dependency 'aws-sdk', '~> 3.1.0'
  s.add_dependency 'basiccache', '~> 1.0.0'
  s.add_dependency 'cymbal', '~> 2.0.0'
  s.add_dependency 'mercenary', '~> 0.4.0'

  s.add_development_dependency 'goodcop', '~> 0.9.7'
end
