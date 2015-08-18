module Ryb
  module VERSION #:nodoc:
    MAJOR, MINOR, PATCH, PRE = [0, 1, 3, 1]
    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
  end

  # Returns the semantic version of Ryb.
  def self.version
    Ryb::VERSION::STRING
  end
end
