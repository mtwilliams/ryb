module Ryb
  module Properties
    module Dependencies
      module ClassMethods
      end

      module InstanceMethods
        def dependencies
          @dependencies ||= []
        end

        def add_dependency(dependency)
          dependencies.push(*dependency)
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
