module Ryb
  module Environment
    include Pourable

    property :paths, Typespec.struct[:includes  => Typespec.array[Typespec.string],
                                     :libraries => Typespec.array[Typespec.string],
                                     :binaries  => Typespec.array[Typespec.string]]
  end
end
