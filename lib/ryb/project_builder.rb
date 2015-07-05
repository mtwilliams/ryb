module Ryb
  class ProjectBuilder
    def build
      # TODO(mtwilliams): Refactor validations.
      Project.new(:name => @name).freeze
    end
  end
end
