module Ryb
  module Toolsets
    AVAILABLE = %w{gmake vs2008 vs2010 vs2012 vs2013 vs2015}
    def self.available?(toolset)
      AVAILABLE.include?(toolset)
    end
  end

  def self.generate_project_files(toolset, projects)
    # ({:gmake  => Ryb::GMake.generate_project_files,
    #   :vs2008 => Ryb::VS2008.generate_project_files,
    #   :vs2010 => Ryb::VS2010.generate_project_files,
    #   :vs2012 => Ryb::VS2012.generate_project_files,
    #   :vs2013 => Ryb::VS2013.generate_project_files,
    #   :vs2015 => Ryb::VS2015.generate_project_files}[toolset](projects))
  end
end
