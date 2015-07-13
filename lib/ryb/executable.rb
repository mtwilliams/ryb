module Ryb
  class Executable
    attr_reader :name
    def initialize(desc={})
      @name = desc[:name]
    end
  end
end
