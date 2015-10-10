$:.push File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'ryb/gem'

Gem::Specification.new do |s|
  s.name              = Ryb::Gem.name
  s.version           = Ryb::Gem.version
  s.platform          = Gem::Platform::RUBY
  s.author            = Ryb::Gem.author.name
  s.email             = Ryb::Gem.author.email
  s.homepage          = Ryb::Gem.homepage
  s.summary           = Ryb::Gem.summary
  s.description       = Ryb::Gem.description
  s.license           = Ryb::Gem.license

  s.required_ruby_version = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_dependency 'gli', '~> 2'
  s.add_dependency 'visual_studio', '~> 0.1'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
end
