module Ryb
  class Application
    include Ryb::Propertied
    property :named

    def initialize(name, opts={})
      @name = Helpers::PrettyString.new(name, pretty: opts[:pretty])
      yield self if block_given?
    end
  end
end
