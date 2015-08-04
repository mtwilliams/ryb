module Ryb
  module Properties
    module Defines
      module ClassMethods
      end

      module InstanceMethods
        def defines
          @defines ||= {}
        end

        def define(new_defines)
          defines.merge!((new_defines.map do |identifier, value|
                            if value.is_a? FalseClass
                              [identifier, '0']
                            elsif value.is_a? TrueClass
                              [identifier, '1']
                            else
                              [identifier, value.to_s]
                            end
                          end).to_h)
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
