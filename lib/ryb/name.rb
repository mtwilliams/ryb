module Ryb
  class Name < String
    attr_reader :pretty
    def initialize(name, pretty=nil)
      super(name); @pretty = pretty;
    end
  end
end
