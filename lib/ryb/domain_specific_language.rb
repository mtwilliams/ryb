module Ryb
  module DomainSpecificLanguage
    def self.project(name, properties={}, &block)
      project_builder = ProjectBuilder.new(Name.new(name, properties[:pretty]))
      Docile.dsl_eval(Delegator.new(project_builder, except: [:build]), &block)
      project = project_builder.build
      return project
    end

    def self.eval(&block)
      projects = []
      Delegator.new(self, except: [:eval],  on_project: (lambda { |project| projects.push(project) })).instance_eval(&block)
      return {:projects => projects}
    end
  end
end
