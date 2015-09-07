require 'ryb/architectures/x86'
require 'ryb/architectures/x86_64'

module Ryb
  module Properties
    module Architectures
      module ClassMethods
      end

      module InstanceMethods
        def architectures
          @architectures ||= {}
        end

        def architecture(name, &block)
          arch = {:x86 => Ryb::Architectures::X86,
                  :x86_64 => Ryb::Architectures::X86_64}[name].new(&block)
          architectures.merge!(name => arch) do |_, *archs|
            archs[0].suffix ||= archs[1].suffix
            archs[0].defines.merge!(archs[1].defines)
            archs[0].files[:source] = archs[0].files[:source] | archs[1].files[:source]
            archs[0].instance_variable_set(:@dependencies, archs[0].dependencies | archs[1].dependencies)
            archs[0]
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
