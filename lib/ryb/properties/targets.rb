require 'ryb/targets/windows'
require 'ryb/targets/macosx'
require 'ryb/targets/linux'

module Ryb
  module Properties
    module Targets
      module ClassMethods
      end

      module InstanceMethods
        def targets
          @targets ||= {}
        end

        def target(name, &block)
          arch = {:windows => Ryb::Targets::Windows,
                  :macosx => Ryb::Targets::MacOSX,
                  :linux => Ryb::Targets::Linux}[name].new(&block)
          targets.merge!(name => arch) do |_, *targets|
            targets[0].instance_variable_set(:@version, targets[1].instance_variable_get(:@version))
            targets[0].suffix ||= targets[1].suffix
            targets[0].defines.merge!(targets[1].defines)
            targets[0]
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
