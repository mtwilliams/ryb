module Ryb
  module Windows
    POSSIBLE_SDK_INSTALL_DIRECTORY_REGISTRY_KEYS =
      ["SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows",
       "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows"]

    def self.sdk
      if Ryb.platform == :windows
        if ENV.key?('WindowsSdkDir')
          ENV['WindowsSdkDir']
        else
          # TODO(mtwilliams): Escape, i.e. .gsub(/\\/,'/').gsub(/\ /,'\\ ')?
          self.sdks.first
        end
      end
    end

    def self.sdk?
      !self.sdk.nil?
    end

    def self.sdks
      if Ryb.platform == :windows
        require 'win32/registry'
        @sdks ||= begin
          (POSSIBLE_SDK_INSTALL_DIRECTORY_REGISTRY_KEYS.map do |key|
            begin
              ::Win32::Registry::HKEY_CURRENT_USER.open(key, ::Win32::Registry::KEY_READ)['CurrentInstallFolder']
            rescue
              begin
                ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)['CurrentInstallFolder']
              rescue
              end
            end
          end).compact
        end
      end
    end
  end
end
