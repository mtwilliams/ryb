module Ryb
  class Configuration < Pour::Mould
    property :name, Typespec.t[Name]

    property :prefix, Typespec.string
    property :suffix, Typespec.string

    pour Environment
    pour Preprocessor
    pour Flags

    pour Code

    pour Dependencies
  end

  class Platform < Configuration
  end

  class Architecture < Configuration
  end
end
