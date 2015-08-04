module Ryb
  module Properties
    module Paths
      module ClassMethods
      end

      module InstanceMethods
        def paths
          @paths ||= {
            :includes => [],
            :libraries => [],
            :binaries => []
          }
        end

        # TODO(mtwilliams): Refactor.
        # TODO(mtwilliams): Verify existence of paths.
        def add_includes_paths(*paths)
          self.paths[:includes].push(*(([*paths]).flatten))
        end

        def add_libraries_paths(*paths)
          self.paths[:libraries].push(*(([*paths]).flatten))
        end

        def add_binaries_paths(*paths)
          self.paths[:binaries].push(*(([*paths]).flatten))
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.include(InstanceMethods)
      end
    end
  end
end
