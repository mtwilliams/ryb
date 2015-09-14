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
    command [:g, :gen, :generate] do |generate|
      generate.action do |global_opts, opts, args|
        toolset = args.shift
        # TODO(mtwilliams): Use custom exception types and refacor out error
        # messages. This will allow us to localize, among other things.
        raise "You failed to specify a toolset!" if toolset.nil?
        raise "You specified an unknown toolset `#{toolset}'!"
      end

      # # TODO(mtwilliams): Make a local option.
      # # TODO(mtwilliams): Rename to 'for', i.e: ryb g nina --for vs2015
      # desc 'Generate a build.ninja file'
      # long_desc 'Generates a build.ninja file for a specific toolchain based on a Rybfile.'
      # flag 'using', :default_value => nil,
      #               :type => String,
      #               :arg_name => 'using',
      #               :desc => 'The toolchain to use'
      # generate.command :ninja do |ninja|
      #   ninja.action do |global_opts, opts, args|
      #     # TODO(mtwilliams): Sanity checks on `args'.
      #     rybfile = args.shift || 'Rybfile'
      #     raise "No such file `#{rybfile}' exists!" unless File.exists?(rybfile)
      #     rybfile = Rybfile.load(rybfile)
      #     puts "Generating project file(s) for Ninja..."
      #     Ryb::Ninja.generate_build_file_for rybfile.project, root: '.', built: '_build', using: global_opts[:using]
      #   end
      # end
    end
  end
end
