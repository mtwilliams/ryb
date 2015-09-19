module Ryb
  module CommandLineInterface
    # TODO(mtwilliams): Look into using Thor?
    require 'gli'
    include GLI::App
    extend self

  # program_name      Ryb::Gem.spec.name
    version           Ryb::Gem.spec.version.to_s
    program_desc      Ryb::Gem.spec.summary
    program_long_desc Ryb::Gem.spec.description

    desc 'Generate project file(s)'
    long_desc 'Generates project files for a specific toolset, based on a Rybfile.'
    command [:g, :gen, :generate] do |gen|
      gen.action do |global_opts, opts, args|
        toolset = args.shift
        # TODO(mtwilliams): Use custom exception types and refacor out error
        # messages. This will allow us to localize, among other things.
        raise "You failed to specify a toolset!" if toolset.nil?
        raise "You specified an unknown toolset `#{toolset}'!"
      end

      gen.command :ninja do |ninja|
        # BUG(mtwilliams): Description isn't being made available.
        desc 'Generate a build.ninja file'
        long_desc 'Generates a build.ninja file for a specific toolchain, based on a Rybfile.'
        ninja.flag 'for', :default_value => 'latest',
                          :type => String,
                          :arg_name => 'for',
                          :desc => 'The toolchain to use'
        ninja.action do |global_opts, opts, args|
          # TODO(mtwilliams): Handle differently per-platform.
          toolchain, sdk = case opts[:for]
                             when 'latest'
                               latest_visual_studio = Ryb::VisualStudio.latest
                               raise "Visual Studio is not available!" unless latest_visual_studio
                               [latest_visual_studio.name, latest_visual_studio.sdks[:windows].first.version]
                             else
                               # TODO(mtwilliams): Use Regex.
                               toolchain, sdk = opts[:for].split('/')[0..1]
                               visual_studio = Ryb::VisualStudio::Install.find(toolchain)
                               raise "#{Ryb::VisualStudio::NAME_TO_PRETTY_NAME[toolchain]} is not available!" unless visual_studio
                               if sdk
                                 raise "Windows SDK #{sdk} is not available." unless visual_studio.sdks[:windows].any?{|sdk| sdk.name.eq?(sdk)}
                               else
                                 sdk = visual_studio.sdks[:windows].first.version
                               end
                               [toolchain, sdk]
                             end
          # TODO(mtwilliams): Sanity checks on `args'.
          # rybfile = args.shift || 'Rybfile'
          # rybfile = Rybfile.load(rybfile)
          # raise "No such file `#{rybfile}' exists!" unless File.exists?(rybfile)
          puts "Generating Ninja build files for #{toolchain}/#{sdk}..."
          # Ryb::Ninja.generate_build_file_for rybfile.project, root: '.', built: '_build', using: global_opts[:using]
        end
      end
    end
  end
end
