$:.push File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'ryb/version'

Gem::Specification.new do |s|
  s.name              = 'ryb'
  s.version           = Ryb.version
  s.platform          = Gem::Platform::RUBY
  s.author            = 'Michael Williams'
  s.email             = 'm.t.williams@live.com'
  s.homepage          = 'https://RubifyYourBuild.com/'
  s.summary           = 'Rubify Your Build!'
  s.description       = 'Ryb is a clean and extensible Ruby DSL for generating project files.'
  s.license           = 'Public Domain'

  s.required_ruby_version = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  # TODO(mtwilliams): Handle this gracefuly in `bin/ryb'.
  s.require_paths = %w(lib)

  s.add_dependency 'facets'
  s.add_dependency 'gli'
  s.add_dependency 'hashie'
  s.add_dependency 'xcodeproj'
  s.add_dependency 'ninja-gen'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
end
