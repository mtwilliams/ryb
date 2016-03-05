module Ryb
  class Dependency < Pour::Mould
  end

  class InternalDependency < Dependency
    property :product, Typespec.symbol

    def initialize(product)
      self.product = product
    end
  end

  class ExternalDependency < Dependency
    # TODO(mtwilliams): Implement external dependencies.
  end
end
