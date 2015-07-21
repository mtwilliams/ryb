module Ryb
  class Project
    attr_reader :name
    def initialize(desc={})
      @name = desc[:name]
    end
  end
end
