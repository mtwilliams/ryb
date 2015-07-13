module Ryb
  class Project
    class DSL
      def initialize(project_builder); @project_builder = project_builder; end
      def executable(*args, &block); @project_builder.executable(*args, &block); end
    end
  end
end
