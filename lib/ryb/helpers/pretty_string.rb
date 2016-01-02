module Ryb
  module Helpers
    class PrettyString < String
      # @!attribute [r] pretty
      #   @return [String] A more readable description of the string.
      attr_reader :pretty

      # @param [Hash] opts Optional arguments.
      # @param [String] str The string.
      # @param opts [String] :pretty A more readable description of the string.
      def initialize(str, opts={})
        super(str)
        @pretty = opts[:pretty] if opts.include? :pretty
      end

      # Perform the comparision on the non-pretty values of all derivatives
      # of strings, i.e. coerce any stringy values into ::String before
      # comparing.
      #
      # @example
      #   greeting_1 = PrettyString.new('greeting', pretty: 'Eh!')
      #   greeting_2 = PrettyString.new('greeting', pretty: 'Aloha!')
      #   greeting_1 == greeting_2 #=> true
      alias :eql? :==
      def ==(other)
        if other.is_a? String
          self.to_s == other.to_s
        else
          super(other)
        end
      end

      # @return [String] A more readable description of the string.
      #
      # @example
      #   greeting = PrettyString.new("greeting", pretty: "How you doin'?") #=> "greeting"
      #   greeting.inspect #=> <Ryb::Helpers::PrettyString "greeting" @pretty: "How you doin'?">
      def inspect
        if self.pretty
          "<#{self.class.to_s} \"#{self.to_s}\" @pretty: \"#{self.pretty}\">"
        else
          "<#{self.class.to_s} \"#{self.to_s}\">"
        end
      end
    end
  end
end
