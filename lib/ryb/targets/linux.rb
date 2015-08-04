require 'ryb/target'

module Ryb
  module Targets
    class Linux < Target
      def initialize(&block)
        super('linux', pretty: 'Linux', &block)
      end
    end
  end
end
