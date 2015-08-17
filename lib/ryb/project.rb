require 'ryb/name'
require 'ryb/properties'

require 'ryb/architecture'
require 'ryb/configuration'
require 'ryb/library'
require 'ryb/application'

module Ryb
  class Project
    include Properties::Named
    include Properties::Defines
    include Properties::Flags
    include Properties::Paths
    include Properties::Architectures
    include Properties::Targets
    include Properties::Configurations

    def initialize(name, opts={})
      @name = Name.new(name, opts[:pretty])
      yield self if block_given?
    end

    def libraries; @libraries ||= [] end
    def library(*args, &block)
      self.libraries << Library.new(*args, &block)
    end

    def applications; @applications ||= [] end
    def application(*args, &block)
      self.applications << Application.new(*args, &block)
    end
  end
end
