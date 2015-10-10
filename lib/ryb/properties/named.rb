module Ryb
  module Properties
    module Named
      module ClassMethods
      end

      module InstanceMethods
        attr_reader :name
      end

      def self.merge(lhs, rhs)
        # TODO(mtwilliams): raise Ryb::Error::Unmergable.new(...)
        raise "Unable to reconcile a difference in names." unless lhs.name == rhs.name
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
