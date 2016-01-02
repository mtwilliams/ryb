module Ryb
  class Dependency < Pour::Mould
  end

  class InternalDependency < Dependency
    property :product, Typespec.symbol
  end

  class ExternalDependency < Dependency
    # TODO(mtwilliams): Implement external dependencies.
  end
end
