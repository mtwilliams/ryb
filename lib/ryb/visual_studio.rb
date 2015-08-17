module Ryb
  module VisualStudio
    POSSIBLE_INSTALL_DIRECTORY_REGISTRY_KEYS =
      ["SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\14.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\14.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\12.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\12.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\12.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\12.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\11.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\11.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\11.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\11.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\10.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\10.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\10.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\10.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\9.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\9.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\9.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\9.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\8.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\8.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\8.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\8.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\7.1\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\7.1\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\7.1\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\7.1\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\7.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\7.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\7.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\7.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\6.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VisualStudio\\6.0\\Setup\\VC",
       "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\6.0\\Setup\\VC",
       "SOFTWARE\\Microsoft\\VCExpress\\6.0\\Setup\\VC"]

    def self.install
      if Ryb.platform == :windows
        if ENV.key?('VCInstallDir')
          ENV['VCInstallDir']
        else
          # TODO(mtwilliams): Escape, i.e. .gsub(/\\/,'/').gsub(/\ /,'\\ ')?
          self.installs.first
        end
      end
    end

    def self.installed?
      !self.install.nil?
    end

    def self.installs
      if Ryb.platform == :windows
        require 'win32/registry'
        @installs ||= begin
          (POSSIBLE_INSTALL_DIRECTORY_REGISTRY_KEYS.map do |key|
            begin
              ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)['ProductDir']
            rescue
            end
          end).compact
        end
      end
    end
  end
end
