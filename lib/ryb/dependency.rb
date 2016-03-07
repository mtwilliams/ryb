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

    def initialize(lib_or_framework)
      self.lib_or_framework = lib_or_framework
    end

    alias :eql? :==
    def ==(other)
      self.lib_or_framework == other.lib_or_framework
    end
  end
end
