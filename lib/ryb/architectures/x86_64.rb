require 'ryb/architecture'

module Ryb
  module Architectures
    class X86_64 < Architecture
      def initialize(&block)
        super('x86_64', pretty: 'x86_64', &block)
      end
    end
  end
end
