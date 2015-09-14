module Ryb
  module Gem
    require 'rubygems'

    # TODO(mtwilliams): Don't use our Gempsec.
    def self.spec
      @spec ||= ::Gem::Specification::load(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'ryb.gemspec')))
    end
  end
end
