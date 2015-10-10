module Ryb
  module Helpers
    class PrettyString < String
      attr_reader :pretty
      def initialize(name, opts={})
        super(name)
        @pretty = opts[:pretty] if opts.include? :pretty
      end

      def eql?(other)
        if other.is_a? String
          # Perform the comparision on the non-pretty values of all derivatives
          # of strings, i.e. coerce Ryb::Helpers::PrettyString and
          # VisualStudio::Helpers::PrettyString into ::String before comparing.
          self.to_s == other.to_s
        else
          super(other)
        end
      end
    end
  end
end
