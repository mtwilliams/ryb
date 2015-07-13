module Ryb
  module DSL
    # TODO(mtwilliams): Refactor into Ryb::Runner? Ryb::Builder?
    def on_project(&block)
      # TODO(mtwilliams): Refactor callback/event handling.
      @_on_project_callbacks ||= []
      @_on_project_callbacks << block
    end

    def project(name=nil, opts={}, &block)
      # TODO(mtwilliams): Freak out if a name is not specified.
      # TODO(mtwilliams): Freak out if `opts` is malformed, i.e. an unknown
      # option is specified or a specified option is invalid.
      project_builder = Ryb::ProjectBuilder.new(opts.merge({:name => name}))
      project = Docile.dsl_eval(project_builder, &block).build
      # TODO(mtwilliams): Handle exceptions.
      @_on_project_callbacks.each { |callback| callback.call(project) } unless @_on_project_callbacks.nil?
      return project
    end
  end
end
