module Ryb
  class Project < Pour::Concrete
    property :name, Typespec.t[Ryb::Name]

    pour Configurations
    pour Enviornment
    pour Preprocessor

    property :products, Typespec.array[Typespec.t[Ryb::Product]]
  end
end
