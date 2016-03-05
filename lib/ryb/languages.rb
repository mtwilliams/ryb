module Ryb
  module Languages
    SUPPORTED = [:c, :cpp, :csharp]

    def self.supported
      SUPPORTED
    end

    def self.supported?(language)
      supported.include?(language)
    end
  end
end
