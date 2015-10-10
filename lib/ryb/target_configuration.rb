module Ryb
  class TargetConfiguration < Configuration
    def initialize(name, opts={})
      super(name, opts)
      yield self if block_given?
    end
  end
end
