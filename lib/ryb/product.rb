module Ryb
  class Product < Pour::Concrete
    property :name, Typespec.t[Ryb::Name]

    property :author,      Typespec.string
    property :description, Typespec.string
    property :license,     Typespec.string
    property :version,     Typespec.string

    # TODO(mtwilliams): Code signing.
    # property :certificate, Typespec.struct[:public  => Typespec.string,
    #                                        :private => Typespec.string]

    pour Configurations
    pour Enviornment
    pour Preprocessor
    pour Flags
    pour Code
    pour Dependencies
  end

  class Application < Product
  end

  class Library < Product
    # Link at compile-time or load-time.
    property :linkage, Typespec.enum[:static, :dynamic]
  end
end
