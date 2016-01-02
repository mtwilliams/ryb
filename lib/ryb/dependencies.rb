module Ryb
  module Dependencies
    include Pour::Pourable

    property :dependencies, Typespec.array[Typespec.t[Dependency]]
  end
end
