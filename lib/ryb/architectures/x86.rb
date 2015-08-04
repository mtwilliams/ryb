require 'ryb/architecture'

module Ryb
  module Architectures
    class X86 < Architecture
      def initialize(&block)
        super('x86', pretty: 'x86', &block)
      end
    end
  end
end
