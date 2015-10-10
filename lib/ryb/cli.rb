module Ryb
  module CommandLineInterface
    # TODO(mtwilliams): Look into using Thor?
    require 'gli'
    include GLI::App
    extend self

  # program_name      Ryb::Gem.name
    version           Ryb::Gem.version.to_s
    program_desc      Ryb::Gem.summary
    program_long_desc Ryb::Gem.description

    desc 'Generate project file(s)'
    long_desc 'Generates project files for a specific toolset, based on a Rybfile.'
    command [:g, :gen, :generate] do |gen|
      gen.action do |global_opts, opts, args|
        # TODO(mtwilliams): Use custom exception types and refactor out error
        # messages. This will allow us to localize, among other things.
        raise "You failed to specify a toolset!" if args.empty?
        toolset = args.shift
        raise "You specified an unknown toolset `#{toolset}'!"
      end

      gen.command :visual_studio do |vs|
        # BUG(mtwilliams): Descriptions aren't being made available.
        desc 'Generate Visual Studio project files'
        long_desc 'Generates Visual Studio projects files, based on a Rybfile.'
        vs.action do |global_opts, opts, args|
          raise "Not implemented, yet."
        end
      end

      gen.command :xcode do |xcode|
        # BUG(mtwilliams): Descriptions aren't being made available.
        xcode.desc 'Generate XCode project files'
        xcode.long_desc 'Generates XCode projects files, based on a Rybfile.'
        xcode.action do |global_opts, opts, args|
          raise "Not implemented, yet."
        end
      end

      gen.command :make do |make|
        # BUG(mtwilliams): Descriptions aren't being made available.
        make.desc 'Generate GNU Makefiles'
        make.long_desc 'Generates GNU Makefiles, based on a Rybfile.'
        make.action do |global_opts, opts, args|
          raise "Not implemented, yet."
        end
      end

      gen.command :ninja do |ninja|
        # BUG(mtwilliams): Descriptions aren't being made available.
        ninja.desc 'Generate Ninja build files'
        ninja.long_desc 'Generates a build.ninja file for a specific toolchain, based on a Rybfile.'
        ninja.flag 'for', :default_value => 'latest',
                          :type => String,
                          :arg_name => 'for',
                          :desc => 'The toolchain to use'
        ninja.action do |global_opts, opts, args|
          raise "Not implemented, yet."
        end
      end
    end
  end
end
