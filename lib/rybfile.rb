require 'ryb'

class Rybfile
  include Ryb::DSL

  def self.load(path)
    rybfile = Rybfile.new

    rybfile.on_project do |project|
      puts project.inspect
    end

    rybfile.instance_eval(File.read(path)).freeze
  end
end
