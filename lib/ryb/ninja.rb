module Ryb
  module Ninja
    class Generator
      def initialize(rybfile, opts)
        @rybfile = rybfile
        @root = opts.fetch(:root, '.')
        @build = opts.fetch(:build, '_build')
        @ninjafile = ::Ninja::File.new
        @path = opts.fetch(:ninjafile, "#{@root}/build.ninja")

        # HACK(mtwilliams): Create directory structure.
        require 'fileutils'
        FileUtils.mkdir_p(["#@build/bin", "#@build/lib", "#@build/obj"])

        # HACK(mtwilliams): Assume VisualStudio.
        @vs = ::VisualStudio.latest
        @vc = @vs.products[:c_and_cpp]
      end

      def generate
        @ninjafile.rule "mv", "move /Y $in $out"
        @ninjafile.rule "cp", "move /Y /B $in $out"

        @ninjafile.save(@path)
      end

      # TODO(mtwilliams): Generate phony commands that proxy to all triplets.
      def on_project(project)
        puts "=> #{project.name.pretty || project.name}"
      end

      def on_product(project, product)
        puts " -> Generating for #{product.name.pretty || product.name}"
      end

      def on_project_triplet(project, tripletised)
      end

      def on_product_triplet(project, product, tripletised)
        tripletised = tripletised.()

        config = tripletised.configuration.name.to_sym
        platform = tripletised.platform.name.to_sym
        arch = tripletised.architecture.name.to_sym

        puts "  ~> #{config} for #{platform} (#{arch})"

        name = product.name.canonicalize
        namespace = "#{name}_#{tripletised.triplet.join('_')}"

        sdk = @vc.sdks[:windows].select{|sdk| sdk.version == '7.1'}.first
        sys_include_paths = @vc.includes + sdk.includes
        sys_lib_paths = @vc.libraries[arch] + sdk.libraries[arch]

        @ninjafile.variable "#{namespace}_cflags_sys", VisualStudio::Compiler.include_paths_to_flags(sys_include_paths).join(' ')
        @ninjafile.variable "#{namespace}_ldflags_sys", VisualStudio::Linker.library_paths_to_flags(sys_lib_paths).join(' ')

        cflags = cflags_for_product(project, product, tripletised)
        arflags = arflags_for_product(project, product, tripletised)
        ldflags = ldflags_for_product(project, product, tripletised)

        @ninjafile.variable "#{namespace}_cflags", cflags.join(' ')
        @ninjafile.variable "#{namespace}_cxxflags", "$#{namespace}_cflags"
        @ninjafile.variable "#{namespace}_arflags", arflags.join(' ')
        @ninjafile.variable "#{namespace}_ldflags", ldflags.join(' ')

        sources = sources_for_product(product, tripletised)
        @ninjafile.variable "#{namespace}_sources", sources.map{|src| "#@root/#{src.path}"}.join(' ')

        deps = deps_for_product(product, tripletised)
        @ninjafile.variable "#{namespace}_deps", deps.join(' ')

        artifacts = artifacts_for_product(product, tripletised)
        @ninjafile.variable "#{namespace}_artifacts", artifacts.join(' ')
        @ninjafile.variable("#{namespace}_as_linkable", artifacts[0]) if product.is_a? Ryb::Library
        @ninjafile.variable "#{namespace}_symbols", artifacts[0].gsub(/\.(exe|lib|dll)/, ".pdb")

        # https://github.com/ninja-build/ninja/blob/d1763746b65cc7349d4ed9478befdb651aa24589/src/msvc_helper_main-win32.cc#L38
        # ninja -t msvc -e _build/#{namespace}.env -- cl.exe ...
        env_block = "#@build/#{namespace}.env_block"
        env = @vc.environment(target: {platform: :windows, architecture: arch})
        # "PATH=#{(@vc.binaries[arch] + sdk.binaries[arch]).join(';')}\0"
        File.write(env_block, env.map{|env_var, value| "#{env_var}=#{value}"}.join("\0"))

        @ninjafile.rule(
          "cc_#{namespace}",
          "ninja -t msvc -e #{env_block} -- cl.exe $#{namespace}_cflags_sys /showIncludes $#{namespace}_cflags /Fd$#{namespace}_symbols /Fo$out /Tc$in",
          dependencies: :msvc
        )

        @ninjafile.rule(
          "cxx_#{namespace}",
          "ninja -t msvc -e #{env_block} -- cl.exe $#{namespace}_cxxflags_sys /showIncludes $#{namespace}_cxxflags /Fd$#{namespace}_symbols /Fo$out /Tp$in",
          dependencies: :msvc
        )

        @ninjafile.rule(
          "ar_#{namespace}",
          "ninja -t msvc -e #{env_block} -- lib.exe $#{namespace}_arflags /OUT:$out $in"
        )

        @ninjafile.rule(
          "ld_#{namespace}",
          "ninja -t msvc -e #{env_block} -- link.exe $#{namespace}_ldflags_sys $#{namespace}_ldflags /OUT:$out $#{namespace}_deps $in"
        )

        @ninjafile.rule(
          "so_#{namespace}",
          "ninja -t msvc -e #{env_block} -- link.exe $#{namespace}_ldflags_sys $#{namespace}_ldflags /DLL /IMPLIB:$#{namespace}_as_linkable /OUT:$out $#{namespace}_deps $in"
        )

        c_sources = sources.select{|src| src.language == :c}.map(&:path).map{|src| "#@root/#{src}"}
        c_objects = c_sources.map{|src| src.gsub(/\.(c)/, ".#{namespace}.obj")}.map{|obj| "#@build/obj/#{obj}"}
        cxx_sources = sources.select{|src| src.language == :cpp}.map(&:path).map{|src| "#@root/#{src}"}
        cxx_objects = cxx_sources.map{|src| src.gsub(/\.(cc|cpp|cxx|c++)/, ".#{namespace}.obj")}.map{|obj| "#@build/obj/#{obj}"}

        @ninjafile.build "cc_#{namespace}", Hash[c_objects.zip(c_sources)]
        @ninjafile.build "cxx_#{namespace}", Hash[cxx_objects.zip(cxx_sources)]

        case product
          when Ryb::Application
            @ninjafile.build "ld_#{namespace}", {artifacts[0] => c_objects + cxx_objects}
            @ninjafile.alias namespace, artifacts[0]
          when Ryb::Library
            case product.linkage
              when :static
                @ninjafile.build "ar_#{namespace}", {artifacts[0] => c_objects + cxx_objects}
                @ninjafile.alias namespace, artifacts[0]
              when :dynamic
                @ninjafile.build "so_#{namespace}", {artifacts[1] => c_objects + cxx_objects}
                @ninjafile.alias namespace, artifacts[1]
              end
          end
      end

      private
        def sources_for_product(product, tripletised)
          sources = [*product.sources] |
                    [*tripletised.configuration.sources] |
                    [*tripletised.platform.sources] |
                    [*tripletised.architecture.sources]
          sources.reject{|src| src.inconsequential}.compact.uniq
        end

        def deps_for_product(product, tripletised)
          deps = [*product.dependencies] |
                 [*tripletised.configuration.dependencies] |
                 [*tripletised.platform.dependencies] |
                 [*tripletised.architecture.dependencies]
          deps.map do |dep|
            case dep
              when Ryb::InternalDependency
                "${#{dep.product}_#{tripletised.triplet.join('_')}_as_linkable}"
              when Ryb::ExternalDependency
                triplet = [tripletised.configuration, tripletised.platform, tripletised.architecture].map(&:name).map(&:to_sym)
                mangled = dep.mangled(*triplet)
                "#{mangled}.lib"
              end
          end
        end

        def artifacts_for_product(product, tripletised)
          name = product.name.canonicalize
          config_suffix = tripletised.configuration.suffix || "_#{tripletised.configuration.name}"
          platform_suffix = tripletised.platform.suffix || "_#{tripletised.platform.name}"
          arch_suffix = tripletised.architecture.suffix || "_#{tripletised.architecture.name}"
          suffix = [config_suffix, platform_suffix, arch_suffix].join('')

          if product.is_a? Ryb::Application
            ["#@build/bin/#{name}#{suffix}.exe"]
          elsif product.is_a? Ryb::Library
            case product.linkage
              when :static
                ["#@build/lib/#{name}#{suffix}.lib"]
              when :dynamic
                ["#@build/lib/#{name}#{suffix}.lib", "#@build/bin/#{name}#{suffix}.dll"]
              end
          end
        end

      private
        def cflags_for_product(project, product, tripletised)
          flags = VisualStudio::Compiler::STANDARD_FLAGS +
                  cflags_for_configuration(tripletised.configuration) +
                  cflags_for_platform(tripletised.platform) +
                  cflags_for_architecture(tripletised.architecture)
          flags += VisualStudio::Compiler.include_paths_to_flags(project.paths.includes) if project.paths
          flags += VisualStudio::Compiler.include_paths_to_flags(product.paths.includes) if product.paths
          flags += VisualStudio::Compiler.defines_to_flags(project.defines)
          flags += VisualStudio::Compiler.defines_to_flags(product.defines)
          flags += VisualStudio::Compiler.architecture_to_flags(tripletised.architecture.name.to_sym)
          flags
        end

        def arflags_for_product(_project, _product, _tripletised)
          %w{/nologo}
        end

        def ldflags_for_product(project, product, tripletised)
          flags = VisualStudio::Linker::STANDARD_FLAGS +
                  ldflags_for_configuration(tripletised.configuration) +
                  ldflags_for_platform(tripletised.platform) +
                  ldflags_for_architecture(tripletised.architecture)
          flags += VisualStudio::Linker.library_paths_to_flags(project.paths.libraries) if project.paths
          flags += VisualStudio::Linker.library_paths_to_flags(product.paths.libraries) if product.paths
          flags += VisualStudio::Linker.architecture_to_flags(tripletised.architecture.name.to_sym)
          # TODO: Linkage.
          flags
        end

      private
        def cflags_for_configuration(config)
          flags = []
          # TODO(mtwilliams): @toolchains.for(target)
          flags += VisualStudio::Compiler.include_paths_to_flags(config.paths.includes) if config.paths
          flags += VisualStudio::Compiler.defines_to_flags(config.defines)
          flags += VisualStudio::Compiler.treat_warnings_as_errors_to_flag(config.treat_warnings_as_errors)
          flags += VisualStudio::Compiler.generate_debug_symbols_to_flag(config.generate_debug_symbols)
          flags += VisualStudio::Compiler.optimization_to_flags(config.optimize)
          flags
        end

        def cflags_for_platform(platform)
          flags = []
          # TODO(mtwilliams): @toolchains.for(target)
          flags += VisualStudio::Compiler.include_paths_to_flags(platform.paths.includes) if platform.paths
          flags += VisualStudio::Compiler.defines_to_flags(platform.defines)
          flags
        end

        def cflags_for_architecture(arch)
          flags = []
          # TODO(mtwilliams): @toolchains.for(target)
          flags += VisualStudio::Compiler.architecture_to_flags(arch.name.canonicalize.to_sym)
          flags += VisualStudio::Compiler.include_paths_to_flags(arch.paths.includes) if arch.paths
          flags += VisualStudio::Compiler.defines_to_flags(arch.defines)
          flags
        end

        def ldflags_for_configuration(config)
          flags = []
          # TODO(mtwilliams): @toolchains.for(target)
          flags += VisualStudio::Linker.library_paths_to_flags(config.paths.libraries) if config.paths
          flags += VisualStudio::Linker.generate_debug_symbols_to_flag(config.generate_debug_symbols)
          flags
        end

        def ldflags_for_platform(platform)
          flags = []
          # TODO(mtwilliams): @toolchains.for(target)
          flags += VisualStudio::Linker.library_paths_to_flags(platform.paths.libraries) if platform.paths
          flags
        end

        def ldflags_for_architecture(arch)
          flags = []
          # TODO(mtwilliams): @toolchains.for(target)
          flags += VisualStudio::Linker.library_paths_to_flags(arch.paths.libraries) if arch.paths
          flags
        end
    end

    def self.generate_from(rybfile, opts={})
      puts "Generating..."
      generator = ::Ryb::Ninja::Generator.new(rybfile, opts)
      ::Rybfile::Walker.new(generator, rybfile, opts).walk
      generator.generate
      puts "Done!"
    end
  end
end
