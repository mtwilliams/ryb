module Ryb
  module Dependencies
    include Pourable

    property :dependencies, Typespec.array[Typespec.t[Ryb::Dependency]]
  end
end
