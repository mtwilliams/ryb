module Ryb
  class LibraryBuilder
    def initialize(name)
      @name = name
    end

    def build
      Library.new(:name => @name).freeze
    end
  end
end
