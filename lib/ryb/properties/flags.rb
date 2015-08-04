module Ryb
  module Properties
    module Flags
      module ClassMethods
      end

      module InstanceMethods
        def flags
          @flags ||= {
            :generate_debug_symbols => false,
            :optimize => :none
          }
        end

        def generate_debug_symbols; flags[:generate_debug_symbols]; end
        def generate_debug_symbols=(do_generate_debug_symbols)
          flags[:generate_debug_symbols] = do_generate_debug_symbols
        end

        def optimize; flags[:optimize]; end
        def optimize=(optimization)
          raise "..." unless [:none, :size, :speed].include?(optimization)
          flags[:optimization] = optimization
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
