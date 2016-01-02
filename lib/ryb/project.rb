module Ryb
  class Project < Pour::Mould
    property :name, Typespec.t[Ryb::Name]

    pour Configurations
    pour Enviornment
    pour Preprocessor

    property :products, Typespec.array[Typespec.t[Ryb::Product]]
  end
end
