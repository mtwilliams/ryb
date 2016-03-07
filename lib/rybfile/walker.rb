require 'ryb'
require 'rybfile'

class Rybfile
  class Walker
    def initialize(vistor, rybfile, opts)
      @vistor = vistor
      @rybfile = rybfile
      @root = opts.fetch(:root, '.')
      @build = opts.fetch(:build, '_build')
      # HACK(mtwilliams): Assume debug, development, and release builds are standard.
      @configurations = opts.fetch(:configurations, %w{debug development release})
      @platforms = opts.fetch(:platforms, Ryb::Helpers::Defaults.targets)
      # HACK(mtwilliams): Assume x86 and x86_64 architectures are standard.
      @architectures = opts.fetch(:architectures, %w{x86 x86_64})
    end

    def walk
      # TODO(mtwilliams): Walk in two steps. The first builds an internal hash
      # of projects and their products that is a deferred copy of this code and
      # caches the results. Then iterate over this tree, passing the the lazy
      # evaluation Proc and let users evalute them. This will cascade when
      # doing dependency resolution (hitting cached versions along the way),
      # thus allowing generators for build systems like Visual Studio, that
      # don't allow us to defer dependency resolution inside, them to be written
      # without much fuss (i.e. write linearly but execute depth-first.)

      on_project(@rybfile.project)
    end

    def on_project(project)
      @vistor.on_project(project)

      project.products.each {|product| on_product(project, product)}

      builds = to_applicable_build_matrix(
        to_canonical_names(project.configurations),
        to_canonical_names(project.platforms),
        to_canonical_names(project.architectures))

      builds.each do |config, platform, arch|
        on_project_triplet(project, [config, platform, arch])
      end
    end

    def on_product(project, product)
      @vistor.on_product(project, product)

      builds = to_applicable_build_matrix(
        to_canonical_names(project.configurations) | to_canonical_names(product.configurations),
        to_canonical_names(project.platforms) | to_canonical_names(product.platforms),
        to_canonical_names(project.architectures) | to_canonical_names(product.architectures))

      builds.each do |config, platform, arch|
        on_product_triplet(project, product, [config, platform, arch])
      end
    end

    def on_project_triplet(project, triplet)
      # TODO(mtwilliams): Extract into a helper function.
      config, platform, arch = *triplet
      config = find_by_canonical_name(project.configurations, config)
      platform = find_by_canonical_name(project.platforms, platform)
      arch = find_by_canonical_name(project.architectures, arch)

      tripletised = lambda {
        Hashie::Mash.new({
          :configuration => config,
          :platform => platform,
          :architecture => arch,
          :triplet => triplet
        })
      }

      @vistor.on_project_triplet(project, tripletised)
    end

    def on_product_triplet(project, product, triplet)
      # TODO(mtwilliams): Extract into a helper function.
      config, platform, arch = *triplet
      project_config   = find_by_canonical_name(project.configurations, config)
      project_platform = find_by_canonical_name(project.platforms, platform)
      project_arch     = find_by_canonical_name(project.architectures, arch)
      product_config   = find_by_canonical_name(product.configurations, config)
      product_platform = find_by_canonical_name(product.platforms, platform)
      product_arch     = find_by_canonical_name(product.architectures, arch)

      # TODO(mtwilliams): Refactor into #merge and #merge!
      config   = merge_configuration_settings(project_config, product_config)
      platform = merge_platform_settings(project_platform, product_platform)
      arch     = merge_architecture_settings(project_arch, product_arch)

      # TODO(mtwilliams): Build a completly flattened description of the product
      # for this |triplet|.

      tripletised = lambda {
        Hashie::Mash.new({
          :configuration => config,
          :platform => platform,
          :architecture => arch,
          :triplet => triplet
        })
      }

      @vistor.on_product_triplet(project, product, tripletised)
    end

    private
      def to_canonical_names(collection)
        [*collection].map(&:name).map(&:canonicalize)
      end

      def match_on_canonical_name(name)
        proc {|obj| obj.name.canonicalize == name.to_s}
      end

      def filter_by_canonical_name(collection, name)
        matcher = match_on_canonical_name(name)
        [*collection].select(&matcher).compact
      end

      def find_by_canonical_name(collection, name)
        filter_by_canonical_name(collection, name).first
      end

    private
      def to_applicable_build_matrix(configurations, platforms, architectures)
        applicable_configurations = configurations & @configurations
        applicable_platforms = platforms & @platforms
        applicable_architectures = architectures & @architectures
        to_build_matrix(applicable_configurations, applicable_platforms, applicable_architectures)
      end

      def to_build_matrix(configurations, platforms, architectures)
        configurations.product(platforms.product(architectures)).map(&:flatten)
      end

    private
      def merge_configuration_settings(base, overlay)
        merged = Ryb::Configuration.new

        merged.name = base.name
        merged.prefix = base.prefix if (base and base.prefix)
        merged.prefix = overlay.prefix if (overlay and overlay.prefix)
        merged.suffix = base.suffix if (base and base.suffix)
        merged.suffix = overlay.suffix if (overlay and overlay.suffix)

        merged.paths = Ryb::Paths.new
        merged.defines = Hash.new

        if base and base.paths
          merged.paths.includes += base.paths.includes
          merged.paths.libraries += base.paths.libraries
          merged.paths.binaries += base.paths.binaries
        end

        if overlay and overlay.paths
          merged.paths.includes += overlay.paths.includes
          merged.paths.libraries += overlay.paths.libraries
          merged.paths.binaries += overlay.paths.binaries
        end

        merged.defines.merge!(base.defines) if base and base.defines
        merged.defines.merge!(overlay.defines) if overlay and overlay.defines

        merged.treat_warnings_as_errors = false
        merged.generate_debug_symbols = false
        merged.link_time_code_generation = false
        merged.optimize = :nothing

        if base
          merged.treat_warnings_as_errors = base.treat_warnings_as_errors unless base.treat_warnings_as_errors().nil?
          merged.generate_debug_symbols = base.generate_debug_symbols unless base.generate_debug_symbols().nil?
          merged.link_time_code_generation = base.link_time_code_generation unless base.link_time_code_generation().nil?
          merged.optimize = base.optimize unless base.optimize().nil?
        end

        if overlay
          merged.treat_warnings_as_errors = overlay.treat_warnings_as_errors unless overlay.treat_warnings_as_errors().nil?
          merged.generate_debug_symbols = overlay.generate_debug_symbols unless overlay.generate_debug_symbols().nil?
          merged.link_time_code_generation = overlay.link_time_code_generation unless overlay.link_time_code_generation().nil?
          merged.optimize = overlay.optimize unless overlay.optimize().nil?
        end

        base_dependencies = base ? (base.dependencies || []) : []
        overlay_dependencies = overlay ? (overlay.dependencies || []) : []
        dependencies = base_dependencies | overlay_dependencies

        merged.dependencies = dependencies

        merged
      end

      def merge_platform_settings(base, overlay)
        merge_configuration_settings(base, overlay)
      end

      def merge_architecture_settings(base, overlay)
        merge_configuration_settings(base, overlay)
      end
  end
end
