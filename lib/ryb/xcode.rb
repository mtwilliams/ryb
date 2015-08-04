require 'ryb/project'

module Ryb
  module XCode
    module Project
    end

    module Target
      def self.setup_for_version(xc_project, xc_target, version)
        xc_target.build_configuration_list.set_setting('SDKROOT', "macosx#{version}")
      end

      def self.add_file_references(xc_project, xc_target, files)
        sources = xc_project.main_group['Source'] || xc_project.main_group.new_group('Source')
        files.each do |file|
          *dirs, file = Pathname(file).each_filename.to_a
          group = dirs.reduce(sources) {|group, dir| group[dir] || group.new_group(dir, dir)}
          ref = group.new_file(file)
          xc_target.add_file_references([ref])
        end
      end
    end

    def self.generate_project_files_for(project, opts={})
      # TODO(mtwilliams): Take into account opts[:root].
      xc_proj = Xcodeproj::Project.new("#{project.name}.xcodeproj")
      puts "Generating #{xc_proj.path}..."

      xc_products_group = xc_proj.main_group['Products']
      xc_products_group_for_libs = xc_products_group.new_group('lib', 'lib')
      xc_products_group_for_bins = xc_products_group.new_group('bin', 'bin')

      project.configurations.each do |name, config|
        xc_build_configuration = xc_proj.build_configuration_list[config.name]
        xc_build_configuration ||= xc_proj.build_configuration_list[config.name.capitalize]
        xc_build_configuration ||= xc_proj.add_build_configuration(config.name, :release)
        xc_build_configuration.name = (config.name.pretty || config.name.capitalize)
        defines = project.defines.merge(config.defines)
        xc_build_configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = defines.map {|name, value| "#{name}=#{value}"}
      end

      xc_proj.build_configuration_list.set_setting('SYMROOT', opts[:built])
      xc_proj.build_configuration_list.set_setting('CONFIGURATION_BUILD_DIR', opts[:built])
      xc_proj.build_configuration_list.sort

      (project.libraries + project.applications).each do |target|
        puts " Adding '#{target.name.pretty || target.name}' as target..."
        type = :application if target.is_a? Ryb::Application
        type = {:static => :static_library, :dynamic => :dynamic_library}[target.linkage] if target.is_a? Ryb::Library
        name = target.name
        platform = :osx
        deployment_target = (target.targets[:macosx].version.to_s if (target.targets[:macosx] and target.targets[:macosx].verison))
        xc_target = xc_proj.new_target(type, name, platform, deployment_target)

        # case type
        # when :application
        #   xc_target.product_reference.move(xc_products_group_for_bins)
        # when :static_library
        #   xc_target.product_reference.move(xc_products_group_for_libs)
        # when :dynamic_library
        #   xc_target.product_reference.move(xc_products_group_for_bins)
        # end
        # xc_target.product_reference.set_source_tree(:group)

        # if target.name.pretty
        #   xc_target.name = target.name.pretty
        #   xc_target.product_name = target.name
        # end

        if target.targets[:macosx] and target.targets[:macosx].verison
          Target.setup_for_version(xc_proj, xc_target, target.targets[:macosx].version)
        end

        # TODO(mtwilliams): Refactor.
        configs = ((project.configurations.keys | target.configurations.keys).map do |config|
          project_config = project.configurations[config]
           if project_config
             project_config = project_config.dup
             project_config.instance_variable_set(:@defines, project.defines.merge(project_config.defines))
           end
          target_config = target.configurations[config]
           if target_config
             target_config = target_config.dup
             target_config.instance_variable_set(:@defines, target.defines.merge(target_config.defines))
           end
          config = if project_config and target_config
                     project_config.instance_variable_set(:@defines, project_config.defines.merge(target_config.defines))
                     project_config
                   else
                     project_config || target_config
                   end

          [config.name, config]
        end).to_h

        configs.each do |name, config|
          xc_build_configuration = xc_target.build_configuration_list[config.name]
          xc_build_configuration ||= xc_target.build_configuration_list[config.name.capitalize]
          xc_build_configuration ||= xc_target.add_build_configuration(config.name, :release)
          xc_build_configuration.name = (config.name.pretty || config.name.capitalize)
          xc_build_configuration.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = config.defines.map {|name, value| "#{name}=#{value}"}
        end

        expand_path_variables = lambda { |path|
          path.gsub(/\:built/, opts[:built])
        }

        includes = target.paths[:includes].map(&expand_path_variables).map(&File.method(:expand_path))
        xc_target.build_configuration_list.set_setting('USER_HEADER_SEARCH_PATHS', includes)
        libraries = target.paths[:libraries].map(&expand_path_variables).map(&File.method(:expand_path))
        libraries.each(&FileUtils.method(:mkdir_p))
        xc_target.build_configuration_list.set_setting('LIBRARY_SEARCH_PATHS', libraries)
        binaries = target.paths[:binaries].map(&expand_path_variables).map(&File.method(:expand_path))
        binaries.each(&FileUtils.method(:mkdir_p))
        # ???

        xc_target.build_configuration_list.sort

        xc_target.build_configuration_list.set_setting('BUILT_PRODUCTS_DIR', opts[:built])
        case type
        when :application
          xc_target.build_configuration_list.set_setting('CONFIGURATION_BUILD_DIR', File.join(opts[:built], 'bin'))
        when :static_library
          xc_target.build_configuration_list.set_setting('CONFIGURATION_BUILD_DIR', File.join(opts[:built], 'lib'))
        when :dynamic_library
          xc_target.build_configuration_list.set_setting('CONFIGURATION_BUILD_DIR', File.join(opts[:built], 'bin'))
        end

        Target.add_file_references(xc_proj, xc_target, target.files[:source])

        target.dependencies.each do |dependency|
          xc_target_for_dep = [*(xc_proj.targets.objects.select {|target| target.product_name == dependency})].first
          if xc_target_for_dep
            xc_target.add_dependency(xc_target_for_dep)
            xc_target
          else
            raise "Not implemented, yet!"
          end
        end
      end

      xc_proj.save
    end
  end
end
