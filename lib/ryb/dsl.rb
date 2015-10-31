module Ryb
  module DomainSpecificLanguage
    module Project
      def application(name, opts={}, &block)
        app = Ryb::Application.new
        app.name = Ryb::Name.new(name, :pretty => opts[:pretty])
        DomainSpecificLanguage.for(app).eval(&block)
      end

      def library(name, opts={}, &block)
        lib = Ryb::Library.new
        lib.name = Ryb::Name.new(name, :pretty => opts[:pretty])
        DomainSpecificLanguage.for(lib).eval(&block)
      end
    end

    module Product
      def author=(author)
        @spec.author = author
      end

      def description=(description)
        @spec.description = description
      end

      def license=(license)
        @spec.license = license
      end

      def version=(version)
        @spec.version = version
      end
    end

    module Application
    end

    module Library
      def linkage=(linkage)
        @spec.linkage = linkage
      end
    end

    module Configurations
      def configuration(name, opts={}, &block)
        config = Ryb::Configuration.new
        config.name = Ryb::Name.new(name, :pretty => opts[:pretty])
        DomainSpecificLanguage.for(config).eval(&block)

        # Refactor this?
        existing_config = (@spec.configurations.select { |existing_config|
          existing_config.name.canonicalize == config.name
        }).first

        # TODO(mtwilliams): Merge.
        config = existing_config.merge(config) if existing_config
        @spec.configurations = config
      end

      def platform(name, opts={}, &block)
        platform = Ryb::Platform.new
        platform.name = Ryb::Name.new(name, :pretty =>)
        DomainSpecificLanguage.for(platform).eval(&block)
      end

      def architecture(name, opts={}, &block)
        arch = Ryb::Architecture.new
        arch.name = Ryb::Name.new(name, :pretty =>)
        DomainSpecificLanguage.for(arch).eval(&block)
      end
    end

    module Environment
      def add_include_path(path)
        @spec.paths.includes = @spec.paths.includes | path
      end

      def add_include_paths(paths_and_patterns)
        [*paths_and_patterns].each do |path_or_pattern|
          [*(Dir.glob(path_or_pattern))].each do |path|
            add_include_path(path)
          end
        end
      end

      def add_library_path(path)
        @spec.paths.libraries = @spec.paths.libraries | path
      end

      def add_library_paths(paths_and_patterns)
        [*paths_and_patterns].each do |path_or_pattern|
          [*(Dir.glob(path_or_pattern))].each do |path|
            add_library_path(path)
          end
        end
      end

      def add_binary_path(path)
        @spec.paths.binaries = @spec.paths.binaries | path
      end

      def add_binary_paths(paths_and_patterns)
        [*paths_and_patterns].each do |path_or_pattern|
          [*(Dir.glob(path_or_pattern))].each do |path|
            add_binary_path(path)
          end
        end
      end
    end

    module Preprocessor
      def define(defines)
        @spec.defines = @spec.defines | defines
      end
    end

    module Flags
      def treat_warnings_as_errors=(flag)
        @spec.treat_warnings_as_errors = flag
      end

      def generate_debug_symbols=(flag)
        @spec.generate_debug_symbols = flag
      end

      def link_time_code_generation=(flag)
        @spec.link_time_code_generation = flag
      end

      def optimize=(goal)
        @spec.optimize = goal
      end
    end

    module Dependencies
      def add_dependency(product)
        @spec.dependencies = @spec.dependencies | Ryb::InternalDependency.new(product)
      end

      def add_external_dependency(lib_or_framework)
        raise "Not implemented, yet."
      end
    end

    def self.for(spec)
      # Build a class
       # For every ancestor we know (http://stackoverflow.com/questions/1328068)
        # Include
      # Instance Eval
      # Rewrite exceptions from Typespec/Pour into Ryb
       # Attach source information (file, line)
    end
  end
end
