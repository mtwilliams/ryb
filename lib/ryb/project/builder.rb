module Ryb
  class Project
    class Builder
      def initialize(opts={})
        @name = Ryb::Name.new(opts[:name], opts[:pretty])
      end

      def executable(name=nil, opts={}, &block)
        # TODO(mtwilliams): Freak out if a name is not specified.
        # TODO(mtwilliams): Freak out if a name is specified twice.
        # TODO(mtwilliams): Freak out if `opts` is malformed, i.e. an unknown
        # option is specified or a specified option is invalid.
        executable_builder = ExecutableBuilder.new(opts.merge({:name => name}))
        executable = Docile.dsl_eval(executable_builder, &block).build
        @executables ||= []
        @executables << executable
        return executable
      end

      # REFACTOR(mtwilliams): Move internal-stuffs out of DSL's scope.
      def build
        # TODO(mtwilliams): Refactor validations.
        Project.new(:name => @name,
                    :executables => @executables).freeze
      end
    end
  end
end
