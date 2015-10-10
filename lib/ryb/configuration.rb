module Ryb
  class Configuration
    include Ryb::Properties::Named

    def initialize(name, opts={})
      @name = Helpers::PrettyString.new(name, pretty: opts[:pretty])
      yield self if block_given?
    end
  end
end
