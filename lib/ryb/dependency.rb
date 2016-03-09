module Ryb
  class Dependency < Pour::Mould
  end

  class InternalDependency < Dependency
    property :product, Typespec.symbol

    def initialize(product)
      self.product = product
    end

    alias :eql? :==
    def ==(other)
      self.product == other.product
    end
  end

  class ExternalDependency < Dependency
    property :lib_or_framework, Typespec.string
    property :mangler, Typespec.or[Typespec.fn, Typespec.nothing]

    def initialize(lib_or_framework, opts={})
      self.lib_or_framework = lib_or_framework
      self.mangler = opts[:mangler]
    end

    def mangled(*triplet)
      if self.mangler()
        self.mangler.(triplet, self.lib_or_framework())
      else
        self.lib_or_framework
      end
    end

    alias :eql? :==
    def ==(other)
      return false unless self.mangler == other.mangler
      self.lib_or_framework == other.lib_or_framework
    end
  end
end
