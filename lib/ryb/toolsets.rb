module Ryb
  module Toolsets
    AVAILABLE = %w{gmake vs2008 vs2010 vs2012 vs2013 vs2015}
    def self.available?(toolset)
      AVAILABLE.include?(toolset)
    end
  end
end
