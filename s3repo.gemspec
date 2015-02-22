Gem::Specification.new do |s|
  s.name        = 's3repo'
  s.version     = '0.0.1'
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.summary     = 'S3 Archlinux repo library'
  s.description = "Simple library for interacting with Archlinux repos in S3"
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/amylum/s3repo'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split
  s.executables = ['s3repo']

  s.add_dependency 'mercenary', '~> 0.3.4'
  s.add_dependency 'aws-sdk', '~> 2.0.0'

  s.add_development_dependency 'rubocop', '~> 0.28.0'
  s.add_development_dependency 'rake', '~> 10.4.0'
  s.add_development_dependency 'coveralls', '~> 0.7.1'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'fuubar', '~> 2.0.0'
end
