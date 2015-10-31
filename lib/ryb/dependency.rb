module Ryb
  class Dependency < Pourable
  end

  class InternalDependency < Dependency
    property :product, Typespec.symbol
  end

  class ExternalDependency < Dependency
    # TODO(mtwilliams): Implement external dependencies.
  end
end
