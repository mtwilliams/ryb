module Ryb
  class ProjectBuilder
    def initialize(name)
      @name = name
      @libraries = []
    end

    def library(name, properties={}, &block)
      library_builder = libraryBuilder.new(Name.new(name, properties[:pretty]))
      Docile.dsl_eval(Delegator.new(library_builder, except: [:build]), &block)
      library = library_builder.build
      libraries.push(library)
      return library
    end

    def build
      Project.new(:name => @name,
                  :libraries => @libraries).freeze
    end
  end
end
