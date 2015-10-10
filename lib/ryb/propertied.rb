module Ryb
  module Propertied
    module ClassMethods
      def property(property)
        @_properties ||= []
        unless @_properties.include? property
          include(_property_to_class(property))
          @_properties << property
        end
      end

      def properties(properties)
        [*properties].each {|p| property(p)}
      end

      def merge(lhs, rhs)
        merge(lhs.dup, rhs)
      end

      def merge!(lhs, rhs)
        @_properties.each do |property|
          _property_to_class(property).merge(lhs, rhs)
        end
      end

      def _property_to_class(property)
        Object.const_get("Ryb::Properties::#{property.to_s.split('_').map{|word| word.capitalize}.join}")
      end
    end

    module InstanceMethods
    end

    def self.included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)
    end
  end
end
