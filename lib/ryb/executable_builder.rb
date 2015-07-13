module Ryb
  class ExecutableBuilder
    def initialize(opts={})
      @name = Ryb::Name.new(opts[:name], opts[:pretty])
    end

    # REFACTOR(mtwilliams): Move internal-stuffs out of DSL's scope.
    def build
      Executable.new(:name => @name).freeze
    end
  end
end
