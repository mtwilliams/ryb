require 'ryb/project'
require 'ryb/windows'
require 'ryb/visual_studio'

module Ryb
  module Ninja
    def self.generate_build_file_for(project, opts={})
      case Ryb.platform
        when :windows
          visual_studio = (Ryb::VisualStudio::VERSIONS.map{|version| Ryb::VisualStudio.find_by_version(version)}).first
          raise 'Unable to find Visual Studio.' unless visual_studio
          raise 'Unable to find Windows SDK.' if visual_studio.sdks.windows.empty?
          windows_sdk = visual_studio.sdks.windows.first
          vc_install_dir = File.join(visual_studio.root, '/VC')

          puts "Generating build.ninja..."
          ::Ninja::File.new "#{opts[:root]}/build.ninja" do
            variable 'root', opts[:root]
            variable 'built', opts[:built]

            # TODO(mtwilliams): Respect project.targets[:windows].sdk.
            variable 'WindowsSdkDir', windows_sdk.root
            variable 'VCInstallDir', vc_install_dir

            variable 'cl', "cl.exe"
            variable 'lib', "lib.exe"
            variable 'link', "link.exe"

            project.configurations.each do |_, config|
              [:windows].map{|target| project.targets[target]}.compact.each do |target|
                [:x86, :x86_64].map{|arch| project.architectures[arch]}.compact.each do |arch|
                  triplet = "#{config.name}_#{target.name}_#{arch.name}"
                  (project.applications+project.libraries).each do |buildable|
                    name = "#{buildable.name.pretty||buildable.name.capitalize} (#{config.name.pretty||config.name.capitalize}) for #{target.name.pretty||target.name.capitalize} (#{arch.name.pretty||arch.name.capitalize})"
                    puts " Adding '#{name}'..."
                    quadruplet = "#{buildable.name}_#{triplet}"
                    variable "#{quadruplet}_name", name
                    variable "#{quadruplet}_suffix",
                             "#{config.suffix||''}#{target.suffix||''}#{arch.suffix||''}"
                    defines = {}
                    flags = {}
                    if buildable.configurations[config.name]
                      defines = buildable.defines.merge(buildable.configurations[config.name].defines)
                      flags = buildable.flags.merge(buildable.configurations[config.name].flags)
                     else
                      defines = buildable.defines
                      flags = buildable.flags
                    end
                    defines = project.defines.merge(arch.defines.merge(target.defines.merge(config.defines.merge(defines))))
                    flags = arch.flags.merge(target.flags.merge(config.flags.merge(flags)))
                    # TODO(mtwilliams): Union paths after expansion.
                    paths = {:includes => project.paths[:includes] | buildable.paths[:includes],
                             :libraries => project.paths[:libraries] | buildable.paths[:libraries],
                             :binaries => project.paths[:binaries] | buildable.paths[:binaries]}
                    expand_path_variables = lambda {|path| path.gsub(/\$built/i, "${built}")}
                    includes = paths[:includes].map(&expand_path_variables).map{|path| File.expand_path(path)}
                    libraries = paths[:libraries].map(&expand_path_variables).map{|path| File.expand_path(path)}
                    binaries = paths[:binaries].map(&expand_path_variables).map{|path| File.expand_path(path)}
                    variable "#{quadruplet}_defines", defines.map{|name, value| "/D#{name}=#{value}"}.join(' ')
                    cflags = []
                    cflags.push("/I\"${WindowsSdkDir}/Include\" /I\"${VCInstallDir}/include\"")
                    cflags.push('/arch:IA32') if arch.name == 'x86'
                    if flags[:generate_debug_symbols]
                      cflags.push('/MDd /Zi')
                    else
                      cflags.push('/MD')
                    end
                    cflags.push({:none => '/Od /RTCsu /fp:precise /fp:except',
                                 :size => '/O1 /fp:fast /fp:except-',
                                 :speed => '/Ox /fp:fast /fp:except-'}[flags[:optimization]||:none])
                    includes.each{|includes_search_dir| cflags.push("/I\"#{includes_search_dir}\"")}
                    ldflags = []
                    if arch.name == 'x86'
                      ldflags.push('/machine:X86')
                      ldflags.push("/LIBPATH:\"${WindowsSdkDir}/Lib\" /LIBPATH:\"${VCInstallDir}/Lib\"")
                    elsif arch.name == 'x86_64'
                      ldflags.push('/machine:X64')
                      ldflags.push("/LIBPATH:\"${WindowsSdkDir}/Lib/x64\" /LIBPATH:\"${VCInstallDir}/Lib/amd64\"")
                    end
                    ldflags.push('/DEBUG') if flags[:generate_debug_symbols]
                    libraries.each{|libraries_search_dir| ldflags.push("/LIBPATH:\"#{libraries_search_dir}\"")}
                    binaries.each{|binaries_search_dir| ldflags.push("/LIBPATH:\"#{binaries_search_dir}\"")}
                    variable "#{quadruplet}_cflags", cflags.join(' ')
                    variable "#{quadruplet}_ldflags", ldflags.join(' ')
                    arflags = []
                    variable "#{quadruplet}_arflags", arflags.join(' ')
                    # TODO(mtwilliams): Refactor into cc, ld, and ar rules, using variables under build(s) for uncommonalities.
                    rule "cc_#{quadruplet}",
                         "${cl} /nologo /c /showIncludes /favor:blend /GF /GR- /W4 ${#{quadruplet}_cflags} ${#{quadruplet}_defines} /Fo$out $in",
                         :dependencies => :msvc
                    rule "ld_#{quadruplet}",
                         "${link} /nologo /manifest:no ${#{quadruplet}_ldflags} /OUT:$out $in"
                    rule "ar_#{quadruplet}",
                         "${lib} /nologo ${#{quadruplet}_arflags} /OUT:$out $in"
                    sources = []
                    dependencies = []
                    if buildable.configurations[config.name]
                      sources = buildable.configurations[config.name].files[:source] | buildable.files[:source]
                      dependencies = buildable.configurations[config.name].dependencies | buildable.dependencies
                    else
                      sources = buildable.files[:source]
                      dependencies = buildable.dependencies
                    end
                    sources = arch.files[:source] | target.files[:source] | config.files[:source] | sources
                    dependencies = arch.dependencies | target.dependencies | config.dependencies | dependencies
                    # TODO(mtwilliams): Handle C#.
                    sources = sources.select{|file| /\.(c|cc|cpp)\z/.match(file)}
                    outputs_to_inputs = Hash[sources.map{|source| ["${built}/obj/#{source.gsub(/\.[^.]+\z/,'')}.#{triplet}.obj", "${root}/#{source}"]}]
                    build "cc_#{quadruplet}", outputs_to_inputs
                    output = "#{buildable.name}${#{quadruplet}_suffix}"
                    inputs = outputs_to_inputs.map{|object,_| object}
                    link_to = []
                    dependencies.each do |dependency|
                      as_buildable = (project.libraries.select{|buildable| buildable.name == dependency}).first
                      if as_buildable
                        case as_buildable.linkage
                          when :static
                            link_to.push("${built}/lib/#{as_buildable.name}${#{as_buildable.name}_#{triplet}_suffix}.lib")
                          when :dynamic
                            # TODO(mtwilliams): Move import libraries to ${built}/lib.
                            link_to.push("${built}/bin/#{as_buildable.name}${#{as_buildable.name}_#{triplet}_suffix}.lib")
                          end
                      else
                        # TODO(mtwilliams): Check search paths for the existence of the library.
                        link_to.push(dependency)
                      end
                    end
                    if buildable.is_a? Ryb::Application
                      build "ld_#{quadruplet}", "${built}/bin/#{output}.exe" => inputs+link_to
                      defaults "${built}/bin/#{output}.exe"
                    elsif buildable.is_a? Ryb::Library
                      case buildable.linkage
                      when :static
                        build "ar_#{quadruplet}", "${built}/lib/#{output}.lib" => inputs
                      when :dynamic
                        # TODO(mtwilliams): Specify -DLL.
                        build "ld_#{quadruplet}", "${built}/bin/#{output}.dll" => inputs+link_to
                      end
                    end
                  end
                end
              end
            end
          end

          # TODO(mtwilliams): Generate shell and batch scripts, instead.
          puts "Generating Makefile..."
          ::File.open("#{opts[:root]}/Makefile", 'w') do |f|
            f.write "# This file was auto-generated by \"#{::File.basename($PROGRAM_NAME, ::File.extname($0))}\".\n"
            f.write "# Do not modify! Instead, modify the aforementioned program.\n\n"

            f.write "WindowsSdkDir := /#{windows_sdk.root.gsub(/\\/,'/').gsub(/\:/,'')}\n\n"
            f.write "VCInstallDir := /#{vc_install_dir.gsub(/\\/,'/').gsub(/\:/,'')}\n"

            f.write "# HACK: The Common7/IDE path might not exist in older versions of Microsoft Visual Studio.\n"
            f.write "CommonTools := $(shell readlink -f \"$(VCInstallDir)/../Common7\")\n\n"

            targets = []
            project.configurations.each do |_, config|
              [:windows].map{|target| project.targets[target]}.compact.each do |target|
                [:x86, :x86_64].map{|arch| project.architectures[arch]}.compact.each do |arch|
                  triplet = "#{config.name}-#{target.name}-#{arch.name}"
                  (project.applications + project.libraries).each do |buildable|
                    quadruplet = "#{buildable.name}-#{triplet}"
                    targets.push(quadruplet)
                  end
                end
              end
            end

            f.write ".PHONY: all clean #{targets.join(' ')}\n"
            f.write "all: #{targets.join(' ')}\n\n"
            f.write "clean: \n"
            f.write "\t@rm -rf #{opts[:built]}\n\n"

            project.configurations.each do |_, config|
              [:windows].map{|target| project.targets[target]}.compact.each do |target|
                [:x86, :x86_64].map{|arch| project.architectures[arch]}.compact.each do |arch|
                  triplet = [config.name, target.name, arch.name]
                  (project.applications + project.libraries).each do |buildable|
                    quadruplet = [buildable.name, triplet]
                    case arch.name
                      when 'x86'
                        f.write "#{quadruplet.join('-')}: export PATH := $(WindowsSdkDir)/bin:$(CommonTools)/IDE:$(VCInstallDir)/bin:$(PATH)\n"
                      when 'x86_64'
                        f.write "#{quadruplet.join('-')}: export PATH := $(WindowsSdkDir)/bin/x64:$(CommonTools)/IDE:$(VCInstallDir)/bin/x86_amd64:$(VCInstallDir)/bin:$(PATH)\n"
                      end
                    f.write "#{quadruplet.join('-')}:\n"
                    suffix = "#{config.suffix||''}#{target.suffix||''}#{arch.suffix||''}"
                    if buildable.is_a? Ryb::Application
                      f.write "\t@ninja #{opts[:built]}/bin/#{buildable.name}#{suffix}.exe\n\n"
                    elsif buildable.is_a? Ryb::Library
                      case buildable.linkage
                      when :static
                        f.write "\t@ninja #{opts[:built]}/lib/#{buildable.name}#{suffix}.lib\n\n"
                      when :dynamic
                        f.write "\t@ninja #{opts[:built]}/bin/#{buildable.name}#{suffix}.dll\n\n"
                      end
                    end
                  end
                end
              end
            end
          end

          puts "Done."
        # when :macosx
        # when :linux
        # when :bsd
        else
          raise 'Unsupported platform!'
        end
    end
  end
end
