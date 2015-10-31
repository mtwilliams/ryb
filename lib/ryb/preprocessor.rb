module Ryb
  module Preprocessor
    include Pourable

    property :defines, Typespec.hash[Typespec.string => Typespec.or[Typespec.nothing,
                                                                    Typespec.boolean,
                                                                    Typespec.number,
                                                                    Typespec.string]]
  end
end
