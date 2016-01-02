module Ryb
  module Configurations
    include Pour::Pourable

    property :confiugurations, Typespec.array[Typespec.t[Configuration]]
    property :platforms,       Typespec.array[Typespec.t[Platform]]
    property :architectures,   Typespec.array[Typespec.t[Architectures]]
  end
end
