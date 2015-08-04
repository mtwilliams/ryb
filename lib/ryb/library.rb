require 'ryb/name'
require 'ryb/properties'

require 'ryb/architecture'
require 'ryb/configuration'

module Ryb
  class Library
    include Properties::Named
    include Properties::Defines
    include Properties::Flags
    include Properties::Paths
    include Properties::Files
    include Properties::Dependencies
    include Properties::Architectures
    include Properties::Targets
    include Properties::Configurations

    def initialize(name, opts={})
      @name = Name.new(name, opts[:pretty])
      yield self if block_given?
    end

    def linkage; @linkage ||= :static; end
    def linkage=(new_linkage)
      @linkage = new_linkage
    end
  end
end
