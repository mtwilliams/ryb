module Ryb
  module VERSION #:nodoc:
    MAJOR, MINOR, PATCH, PRE = [0, 0, 0, 'dev']
    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
  end

  def self.version
    Ryb::VERSION::STRING
  end
end
