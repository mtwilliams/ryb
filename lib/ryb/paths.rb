module Ryb
  Paths = Struct.new(:includes, :libraries, :binaries) do
    def initialize(includes=[], libraries=[], binaries=[])
      super
    end
  end
end
