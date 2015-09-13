module Ryb
  module Windows
    def self.sdk?
      %w{10.0 8.1 8.0 7.1 7.0}.any? { |version| Windows::SDK.exists?(version) }
    end

    class SDK
      attr_reader :name
      attr_reader :version
      attr_reader :root

      def initialize(opts={})
        @name = opts[:name]
        @version = opts[:version]
        @root = opts[:root]
      end

      def self.exists?(version)
        !!(find(version))
      end

      def self.find(version)
        find_by_version(version)
      end

      def self.find_by_version(version)
        name, install = _find_install_via_registry(version)
        return if install.nil?

        # TODO(mtwilliams): Cache.
        Windows::SDK.new(name: name,
                         version: version,
                         root: install)
      end

      private
        def self._find_install_via_registry(version)
          keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}A",
                  "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}A",
                  "SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}",
                  "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}"]
          keys.each do |key|
            begin
              require 'win32/registry'
              key = ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)
              return [key['ProductName'], File.expand_path(key['InstallationFolder']).to_s]
            rescue
            end
          end
          return nil
        end
    end
  end
end
