module Ryb
  module Configurations
    include Pour::Pourable

    property :configurations, Typespec.array[Typespec.t[Configuration]]
    property :platforms,      Typespec.array[Typespec.t[Platform]]
    property :architectures,  Typespec.array[Typespec.t[Architecture]]
  end
end
