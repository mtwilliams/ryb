module Ryb
  module Configurations
    include Pourable

    property :confiugurations, Typespec.array[Typespec.t[Ryb::Configuration]]
    property :platforms,       Typespec.array[Typespec.t[Ryb::Platform]]
    property :architectures,   Typespec.array[Typespec.t[Ryb::Architectures]]
  end
end
