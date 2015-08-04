module Ryb
  module Properties
    module Files
      module ClassMethods
      end

      module InstanceMethods
        def files
          @files ||= {
            :source => []
          }
        end

        def add_source_files(*files)
          self.files[:source].push(*((([*files]).flatten).map(&Dir.method(:glob)).flatten))
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
