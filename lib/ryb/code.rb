module Ryb
  module Code
    include Pour::Pourable

    property :sources, Typespec.array[Typespec.t[SourceFile]]
  end
end
