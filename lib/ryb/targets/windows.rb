require 'ryb/target'

module Ryb
  module Targets
    class Windows < Target
      attr_accessor :sdk

      def initialize(&block)
        super('windows', pretty: 'Windows', &block)
      end
    end
  end
end
