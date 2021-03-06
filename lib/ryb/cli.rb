module Ryb
  # TODO(mtwilliams): Collate these somewhere else.
  PLATFORMS = %w{windows macosx linux}
  TOOLCHAINS = %w{msvc clang+llvm gcc}

  module CommandLineInterface
    # TODO(mtwilliams): Look into using Thor?
    require 'gli'
    include GLI::App
    extend self

  # program_name      Ryb::Gem.name
    version           Ryb::Gem.version.to_s
    program_desc      Ryb::Gem.summary
    program_long_desc Ryb::Gem.description

    desc ''
    flag [:root], :default_value => '.'

    desc ''
    flag [:build], :default_value => '_build'

  # TODO(mtwilliams): Use a proper logger.
  # switch :verbose, :default => false,
  #                  :negatable => false

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
        vs.desc 'Generate Visual Studio project files'
        vs.long_desc 'Generates Visual Studio projects files, based on a Rybfile.'
        vs.action do |global_opts, opts, args|
          rybfile = Rybfile.load(args.shift || "Rybfile")
          raise "Not implemented, yet."
        end
      end

      gen.command :xcode do |xcode|
        # BUG(mtwilliams): Descriptions aren't being made available.
        xcode.desc 'Generate XCode project files'
        xcode.long_desc 'Generates XCode projects files, based on a Rybfile.'
        xcode.action do |global_opts, opts, args|
          rybfile = Rybfile.load(args.shift || "Rybfile")
          raise "Not implemented, yet."
        end
      end

      gen.command :gmake do |gmake|
        # BUG(mtwilliams): Descriptions aren't being made available.
        gmake.desc 'Generate GNU Makefiles'
        gmake.long_desc 'Generates GNU Makefiles, based on a Rybfile.'
        gmake.action do |global_opts, opts, args|
          rybfile = Rybfile.load(args.shift || "Rybfile")
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
          rybfile = Rybfile.load(args.shift || "Rybfile")

          # # TODO(mtwilliams): Refactor out.
          # # TODO(mtwilliams): Verify every platform+architecture is supported.
          # targets = [*global_opts[:targets].split(';')].flat_map { |platform, architectures|
          #   architectures = [*(architectures.split(',') || ['*'])]
          #   [].fill(platform, 0, architectures.length).zip(architectures)
          # }

          # toolchains = begin
          #   pairings = global_opts[:toolchains].split(',')
          #   Hash[pairings.map { |pairing|
          #     platform, toolchain = *pairing.split(':')
          #     [platform, toolchain]
          #   }]
          # end

          Ryb::Ninja.generate_from(rybfile, root: global_opts[:root],
                                            build: global_opts[:build],
                                            targets: ['windows'],
                                            toolchains: ['msvc'])
        end
      end
    end
  end
end
