require 'ryb/name'
require 'ryb/properties'

module Ryb
  class Target
    include Properties::Named
    include Properties::Suffix
    include Properties::Defines
    include Properties::Flags

    def initialize(name, opts={})
      @name = Name.new(name, opts[:pretty])
      yield self if block_given?
    end
  end
end
