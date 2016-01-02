require 'ryb'

class Rybfile < Pour::Mould
  property :project, Typespec.t[Ryb::Project]

  class DomainSpecificLanguage
    def initialize(rybfile)
      @rybfile = rybfile
    end

    def project(name, opts={}, &block)
      # TODO(mtwilliams): Allow multiple projects?
      # TODO(mtwilliams): Allow other Rybfiles to be 'included'.
      @rybfile.project = Ryb::Project.new
      @rybfile.project.name = Ryb::Name.new(name, :pretty => opts[:pretty])

      DomainSpecificLanguage.for(@rybfile.project).instance_eval(&block)
    end

    def self.for(rybfile)
      # Hide behind a SimpleDelegator so users don't play with our internals.
      SimpleDelegator.new(self.new(rybfile))
    end
  end

  def self.load(path)
    rybfile = Rybfile.new

    # TODO(mtwilliams): Rewrite exceptions from Typespec/Pour into Ryb and attach
    # source information (the file and line number from the responsible Rybfile.)
    DomainSpecificLanguage.for(rybfile).instance_eval("lambda {#{File.read(rybfile)}}")

    rybfile
  end
end
