module Ryb
  class Name < String
    attr_reader :pretty
    def initialize(name, pretty)
      super(name)
      @pretty = pretty
    end
  end
end
