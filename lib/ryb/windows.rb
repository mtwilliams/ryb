module Ryb
  module Windows
    class SDK
      VERSIONS = %w{10.0 8.1 8.0 7.1 7.0}

      attr_reader :name,
                  :version,
                  :root,
                  :includes,
                  :libraries,
                  :binaries,
                  :supports

      def supports?(arch)
        @supports.include?(arch)
      end

      def initialize(desc={})
        @name      = desc[:name]
        @version   = desc[:version]
        @root      = desc[:root]
        @includes  = desc[:includes]
        @libraries = desc[:libraries]
        @binaries  = desc[:binaries]
        @supports  = desc[:supports]
      end

      def self.installed?(version)
        !!(find(version))
      end

      def self.find(version)
        find_by_version(version) if VERSIONS.include?(version)
      end

      def self.find_by_version(version)
        # TODO(mtwilliams): Cache.
        case version.to_f
          when 7.0..7.1
            # Find a Windows SDK via the registry.
            name, root = self._find_via_registry(version)
            return nil if root.nil?

            # We expand paths to get capitalization correct. Although not
            # strictly necessary it does make users' lives easier.
            includes  = [File.expand_path(File.join(root, 'include'))]
            # TODO(mtwilliams): Handle 64-bit and ARM compiler host variants.
            libraries = {:x86    => [File.expand_path(File.join(root, 'lib'))],
                         :x86_64 => [File.expand_path(File.join(root, 'lib', 'x64'))].select{|path| Dir.exists?(path)}}
            binaries  = {:x86    => [File.expand_path(File.join(root, 'bin'))],
                         :x86_64 => [File.expand_path(File.join(root, 'bin', 'x64'))].select{|path| Dir.exists?(path)}}

            # This is also to make users' lives easier.
            supports = []
             supports << :x86
             supports << :x86_64 unless libraries[:x86_64].empty?

            Windows::SDK.new(name: name,
                             version: version,
                             root: root,
                             includes: includes,
                             libraries: libraries,
                             binaries: binaries,
                             supports: supports)
          when 8.0
            # Find the Windows Kit.
            name, root = self._find_kit_via_registry(version)
            return nil if root.nil?

            # Again, we expand paths to make users' lives easier.
            includes = [File.expand_path(File.join(root, 'include', 'shared')),
                        File.expand_path(File.join(root, 'include', 'um'))]
            libraries = {:x86    => [File.expand_path(File.join(root, 'lib', 'win8', 'um', 'x86'))],
                         :x86_64 => [File.expand_path(File.join(root, 'lib', 'win8', 'um', 'x64'))]}
            binaries  = {:x86    => [File.expand_path(File.join(root, 'bin', 'x86'))],
                         :x86_64 => [File.expand_path(File.join(root, 'bin', 'x64'))]}

            Windows::SDK.new(name: name,
                             version: version,
                             root: root,
                             includes: includes,
                             libraries: libraries,
                             binaries: binaries,
                             supports: [:x86, :x86_64])
          when 8.1
            # Find the Windows Kit.
            name, root = self._find_kit_via_registry(version)
            return nil if root.nil?

            # Again, we expand paths to make users' lives easier.
            includes = [File.expand_path(File.join(root, 'include', 'shared')),
                        File.expand_path(File.join(root, 'include', 'um'))]
            libraries = {:x86    => [File.expand_path(File.join(root, 'lib', 'winv6.3', 'um', 'x86'))],
                         :x86_64 => [File.expand_path(File.join(root, 'lib', 'winv6.3', 'um', 'x64'))],
                            :arm => [File.expand_path(File.join(root, 'lib', 'winv6.3', 'um', 'arm'))]}
            binaries  = {:x86    => [File.expand_path(File.join(root, 'bin', 'x86'))],
                         :x86_64 => [File.expand_path(File.join(root, 'bin', 'x64'))],
                            :arm => [File.expand_path(File.join(root, 'bin', 'arm'))]}

            Windows::SDK.new(name: name,
                             version: version,
                             root: root,
                             includes: includes,
                             libraries: libraries,
                             binaries: binaries,
                             supports: [:x86, :x86_64, :arm])
          when 10.0
            # Find the Windows Kit.
            name, root = self._find_kit_via_registry(version)
            return nil if root.nil?

            # HACK(mtwilliams): Determine the latest and greatest version by
            # finding the directory with the highest version number. We should
            # look into using the 'PlatformIdentity' attribute in SDKManifest.xml.
            version = Dir.entries(File.join(root, 'lib')).sort.last

            # Again, we expand paths to make users' lives easier.
            includes = [File.expand_path(File.join(root, 'include', version, 'ucrt')),
                        File.expand_path(File.join(root, 'include', version, 'shared')),
                        File.expand_path(File.join(root, 'include', version, 'um'))]
            libraries = {:x86    => [File.expand_path(File.join(root, 'lib', version, 'ucrt', 'x86')),
                                     File.expand_path(File.join(root, 'lib', version, 'um', 'x86'))],
                         :x86_64 => [File.expand_path(File.join(root, 'lib', version, 'ucrt', 'x64')),
                                     File.expand_path(File.join(root, 'lib', version, 'um', 'x64'))],
                            :arm => [File.expand_path(File.join(root, 'lib', version, 'ucrt', 'arm')),
                                     File.expand_path(File.join(root, 'lib', version, 'um', 'arm'))]}
            binaries  = {:x86    => [File.expand_path(File.join(root, 'bin', 'x86'))],
                         :x86_64 => [File.expand_path(File.join(root, 'bin', 'x64'))],
                            :arm => [File.expand_path(File.join(root, 'bin', 'arm'))]}

            Windows::SDK.new(name: name,
                             version: '10.0',
                             root: root,
                             includes: includes,
                             libraries: libraries,
                             binaries: binaries,
                             supports: [:x86, :x86_64, :arm])
          else
            if version.to_f <= 7.0
              raise "Ryb does not support older Windows SDKs. Microsoft doesn't either."
            else
              raise "I thought Windows 10 was the last version!"
            end
          end
      end

      private
        def self._find_via_registry(version)
          keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}A",
                  "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}A",
                  "SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}",
                  "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}"]
          installs = keys.map do |key|
            begin
              require 'win32/registry'
              key = ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)
              [key['ProductName'], File.expand_path(key['InstallationFolder']).to_s]
            rescue
            end
          end
          installs.compact.first
        end

        def self._find_kit_via_registry(version)
          names = {'10.0' => "Windows Kit for Universal Windows",
                   '8.1'  => "Windows Kit for Windows 8.1",
                   '8.0'  => "Windows Kit for Windows 8.0"}
          keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\Windows Kits\\Installed Roots",
                  "SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots"]
          properties = {'10.0' => "KitsRoot10",
                        '8.1'  => "KitsRoot81",
                        '8.0'  => "KitsRoot"}
          installs = keys.map do |key|
            begin
              require 'win32/registry'
              root = ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)[properties[version]]
              File.expand_path(root).to_s
            rescue
            end
          end
          [names[version], installs.compact.first]
        end
    end

    def self.sdk?
      Windows::SDK::VERSIONS.any?{|version| Windows::SDK.installed?(version)}
    end
  end
end
