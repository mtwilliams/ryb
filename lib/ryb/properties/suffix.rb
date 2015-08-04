module Ryb
  module Properties
    module Suffix
      module ClassMethods
      end

      module InstanceMethods
        attr_accessor :suffix
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
