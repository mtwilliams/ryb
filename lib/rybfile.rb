class Rybfile < Pour::Concrete
  property :project, Typespec.t[Ryb::Project]

  class DomainSpecificLanguage
    def initialize(rybfile)
      @rybfile = rybfile
    end

    def project(name, opts={}, &block)
      @rybfile.project = Ryb::Project.new
      @rybfile.project.name = Ryb::Name.new(name, :pretty => opts[:pretty])
      DomainSpecificLanguage.for(@rybfile.project).eval(&block)
    end
  end
end
