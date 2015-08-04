require 'ryb'
require 'ostruct'

# TODO(mtwilliams): Improve the handling of Rybfiles.
module Rybfile
  def self.load(path)
    begin
      return OpenStruct.new(:project => eval(File.read(path), binding(), path)).freeze
    rescue SignalException, SystemExit
      raise
    rescue SyntaxError, Exception => e
      raise "Invalid Rybfile!\n #{path}\n #{e}"
    end
  end
end
