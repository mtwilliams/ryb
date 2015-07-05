module Ryb
  module DSL
    # TODO(mtwilliams): Refactor into Ryb::Runner? Ryb::Builder?
    def on_project(&block)
      @_on_project_callbacks ||= []
      @_on_project_callbacks << block
    end

    def project(name=nil, opts={}, &block)
      # TODO(mtwilliams): Freak out if a name is not specified.
      # TODO(mtwilliams): Freak out if `opts` is malformed, i.e. an unknown
      # option is specified or a specified option is invalid.
      project = Docile.dsl_eval(Ryb::ProjectBuilder.new, &block).build

      # TODO(mtwilliams): Handle exceptions.
      @_on_project_callbacks.each { |callback| callback.call(project) } unless @_on_project_callbacks.nil?

      return project
    end
  end
end
