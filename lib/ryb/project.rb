module Ryb
  class Project < Pour::Mould
    property :name, Typespec.t[Ryb::Name]

    pour Configurations
    pour Environment
    pour Preprocessor

    property :products, Typespec.array[Typespec.t[Ryb::Product]]
  end
end
