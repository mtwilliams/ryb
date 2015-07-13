require 'ryb'

class Rybfile
  include Ryb::DSL

  def initialize
    @projects = []
    on_project { |project| @projects << project }
  end

  def self.load(path)
    rybfile = Rybfile.new
    rybfile.instance_eval(File.read(path)).freeze
    # puts rybfile.projects.inspect
    return rybfile
  end
end
