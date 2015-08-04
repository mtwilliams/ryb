require 'ryb/target'

module Ryb
  module Targets
    class MacOSX < Target
      class Version
        attr_accessor :major
        attr_accessor :minor

        def initialize(major, minor)
          @major = major; @minor = minor;
        end

        def to_s
          "#{major}.#{minor}"
        end
      end

      attr_reader :version
      def version=(version)
        raise "..." unless version =~ /^(\d+)\.(\d+)$/
        major, minor = *((/^(\d+)\.(\d+)$/.match(version))[1..2].map(&:to_i))
        raise "..." if major != 10
        raise "..." if minor <= 5
        @version = Version.new(major, minor)
      end

      def initialize(&block)
        super('macosx', pretty: 'Mac OS X', &block)
      end
    end
  end
end
