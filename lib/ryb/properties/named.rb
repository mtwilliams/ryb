module Ryb
  module Properties
    module Named
      module ClassMethods
      end

      module InstanceMethods
        attr_reader :name
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
