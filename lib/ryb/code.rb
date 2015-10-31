module Ryb
  module Code
    include Pourable

    property :sources, Typespec.array[Typespec.t[Ryb::SourceFile]]
  end
end
