require 'rbconfig'
require 'hashie'

module Ryb
  def self.platform
    @platform ||= begin
      case RbConfig::CONFIG['host_os']
        when /mswin|msys|mingw/
          :windows
        when /mac os|darwin/
          :macosx
        when /linux/
          :linux
        when /bsd/
          :bsd
        else
          raise 'Unknown or unsupported platform!'
        end
    end
  end

  require 'ryb/version'

  require 'ryb/project'
  require 'ryb/library'
  require 'ryb/application'

  require 'ryb/ninja'
end
