module Ryb
  module DomainSpecificLanguage
    module Configurations
      def configuration(name, opts={}, &block)
        @spec.configurations ||= []

        existing_config = find_by_canonical_name(@spec.configurations, name)
        config = existing_config || Ryb::Configuration.new
        existing_pretty_name = config.name.pretty if existing_config
        config.name = Ryb::Name.new(name, :pretty => existing_pretty_name || opts[:pretty])

        @spec.configurations << config unless existing_config

        DomainSpecificLanguage.for(config).instance_eval(&block)
      end

      def platform(name, opts={}, &block)
        # TODO(mtwilliams): Refactor this.
        @spec.platforms ||= []

        existing_platform = find_by_canonical_name(@spec.platforms, name)
        platform = existing_platform || Ryb::Platform.new
        existing_pretty_name = platform.name.pretty if existing_platform
        platform.name ||= Ryb::Name.new(name, :pretty => existing_pretty_name || opts[:pretty])

        @spec.platforms << platform unless existing_platform

        DomainSpecificLanguage.for(platform).instance_eval(&block)
      end

      def architecture(name, opts={}, &block)
        # TODO(mtwilliams): Refactor this.
        @spec.architectures ||= []

        existing_arch = find_by_canonical_name(@spec.architectures, name)
        arch = existing_arch || Ryb::Architecture.new
        existing_pretty_name = arch.name.pretty if existing_arch
        arch.name ||= Ryb::Name.new(name, :pretty => existing_pretty_name || opts[:pretty])

        @spec.architectures << arch unless existing_arch

        DomainSpecificLanguage.for(arch).instance_eval(&block)
      end

      private
        def find_by_canonical_name(ary_of_named_things, name)
          (ary_of_named_things.select do |existing_thing|
              existing_thing.name.canonicalize == name.to_s
            end).first
        end
    end

    module Environment
      def add_include_path(path)
        @spec.paths ||= Paths.new
        @spec.paths.includes = @spec.paths.includes + [path]
      end

      def add_include_paths(*paths_and_patterns)
        [*paths_and_patterns].each do |path_or_pattern|
          [*(Dir.glob(path_or_pattern))].each do |path|
            add_include_path(path)
          end
        end
      end

      def add_library_path(path)
        @spec.paths ||= Paths.new
        @spec.paths.libraries = @spec.paths.libraries + [path]
      end

      def add_library_paths(*paths_and_patterns)
        [*paths_and_patterns].each do |path_or_pattern|
          [*(Dir.glob(path_or_pattern))].each do |path|
            add_library_path(path)
          end
        end
      end

      def add_binary_path(path)
        @spec.paths ||= Paths.new
        @spec.paths.binaries = @spec.paths.binaries + [path]
      end

      def add_binary_paths(*paths_and_patterns)
        [*paths_and_patterns].each do |path_or_pattern|
          [*(Dir.glob(path_or_pattern))].each do |path|
            add_binary_path(path)
          end
        end
      end
    end

    module Preprocessor
      def define(defines)
        @spec.defines ||= Hash.new
        @spec.defines = @spec.defines.merge(defines)
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

    module Code
      def add_source_file(file)
        case file
          when SourceFile
            @spec.sources ||= []
            @spec.sources = @spec.sources + [file]
          when String
            add_source_file(SourceFile.new(file))
          end
      end

      def add_source_files(*files_and_patterns)
        [*files_and_patterns].each do |file_or_pattern|
          case file_or_pattern
            when SourceFile
              add_source_file(file_or_pattern)
            when String
              [*(Dir.glob(file_or_pattern))].each do |file|
                add_source_file(file)
              end
            end
        end
      end
    end

    module Dependencies
      def add_dependency(product)
        @spec.dependencies ||= []
        @spec.dependencies = @spec.dependencies + [Ryb::InternalDependency.new(product)]
      end

      def add_external_dependency(lib_or_framework)
        raise "Not implemented, yet."
      end
    end

    class Configuration
      def initialize(config)
        @spec = @config = config
      end

      def prefix=(prefix)
        @config.prefix = prefix
      end

      def suffix=(suffix)
        @config.suffix = suffix
      end

      include Environment
      include Preprocessor
      include Flags
      include Code
      include Dependencies
    end

    class Platform < Configuration
      def initialize(platform)
        super(platform)
        @platform = platform
      end
    end

    class Architecture < Configuration
      def initialize(arch)
        super(arch)
        @arch = arch
      end
    end

    class Product
      def initialize(product)
        @spec = @product = product
      end

      def author=(author)
        @product.author = author
      end

      def description=(description)
        @product.description = description
      end

      def license=(license)
        @product.license = license
      end

      def version=(version)
        @product.version = version
      end

      include Configurations
      include Environment
      include Preprocessor
      include Flags
      include Code
      include Dependencies
    end

    class Application < Product
      def initialize(app)
        super(app)
        @app = app
      end
    end

    class Library < Product
      def initialize(lib)
        super(lib)
        @lib = lib
      end

      def linkage=(linkage)
        @lib.linkage = linkage
      end
    end

    class Project
      def initialize(project)
        @spec = @project = project
      end

      include Configurations
      include Environment
      include Preprocessor

      def application(name, opts={}, &block)
        # TODO(mtwilliams): Verify uniqueness.
        app = Ryb::Application.new
        app.name = Ryb::Name.new(name, :pretty => opts[:pretty])
        DomainSpecificLanguage.for(app).instance_eval(&block)
        @project.products ||= []
        @project.products = @project.products + [app]
      end

      def library(name, opts={}, &block)
        # TODO(mtwilliams): Verify uniqueness.
        lib = Ryb::Library.new
        lib.name = Ryb::Name.new(name, :pretty => opts[:pretty])
        DomainSpecificLanguage.for(lib).instance_eval(&block)
        @project.products ||= []
        @project.products = @project.products + [lib]
      end
    end

    FOR = {Ryb::Configuration => Configuration,
           Ryb::Platform      => Platform,
           Ryb::Architecture  => Architecture,
           Ryb::Application   => Application,
           Ryb::Library       => Library,
           Ryb::Project       => Project}

    def self.for(obj)
      # TODO(mtwilliams): Use `__poured__` rather than manually building?
      # poured = spec.class_variable_get(:@@__poured__)

      # Hide behind a SimpleDelegator so users don't play with our internals.
      SimpleDelegator.new(FOR[obj.class].new(obj))
    end
  end
end
