require 'ryb'

module Rybfile
  def self.load(path)
    procified = eval("Proc.new { #{File.read(path)} }")
    rybfile = OpenStruct.new(Ryb::DomainSpecificLanguage.eval &procified)
    return rybfile.freeze
  end
end
