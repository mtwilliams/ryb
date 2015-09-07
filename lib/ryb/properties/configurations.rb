module Ryb
  module Properties
    module Configurations
      module ClassMethods
      end

      module InstanceMethods
        def configurations
          @configurations ||= {}
        end

        def configuration(name, opts={}, &block)
          config = Configuration.new(name, opts, &block)
          configurations.merge!(name => config) do |_, *configs|
            configs[0].suffix ||= configs[1].suffix
            configs[0].defines.merge!(configs[1].defines)
            configs[0].instance_variable_set(:@flags, configs[1].instance_variable_get(:@flags))
            configs[0].files[:source] = configs[0].files[:source] | configs[1].files[:source]
            configs[0].instance_variable_set(:@dependencies, configs[0].dependencies | configs[1].dependencies)
            configs[0]
          end
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
