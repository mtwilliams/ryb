module Ryb
  module VisualStudio
    NAMES        = ['vs2015', 'vs2013', 'vs2012', 'vs2010', 'vs2008', 'vs2005']

    PRETTY_NAMES = ['Visual Studio 2015', 'Visual Studio 2013',
                    'Visual Studio 2012', 'Visual Studio 2010',
                    'Visual Studio 2008', 'Visual Studio 2005']

    VERSIONS     = [14.0, 12.0, 11.0, 10.0, 9.0, 8.0].map(&:to_s)

    SDKS         = [{windows:  %w{10.0 8.1 8.0 7.1}},
                    {windows:       %w{8.1 8.0 7.1}},
                    {windows:       %w{8.1 8.0 7.1}},
                    {windows:       %w{8.1 8.0 7.1}},
                    {windows:               %w{7.1 7.0}},
                    {windows:               %w{7.1 7.0}}]

    NAME_TO_VERSION = Hash[NAMES.zip(VERSIONS)]
    NAME_TO_PRETTY_NAME = Hash[NAMES.zip(PRETTY_NAMES)]
    NAME_TO_SDKS = Hash[NAMES.zip(SDKS)]

    VERSION_TO_NAME = Hash[VERSIONS.zip(NAMES)]
    VERSION_TO_PRETTY_NAME = Hash[VERSIONS.zip(PRETTY_NAMES)]
    VERSION_TO_SDKS = Hash[VERSIONS.zip(SDKS)]

    class Install
      attr_reader :name,
                  :version,
                  :root,
                  :includes,
                  :libraries,
                  :binaries,
                  :sdks,
                  :supports

      def supports?(lang_or_arch)
        @supports.include?(lang_or_arch)
      end

      def initialize(desc={})
        @name      = desc[:name]
        @version   = desc[:version]
        @root      = desc[:root]
        @includes  = desc[:includes]
        @libraries = desc[:libraries]
        @binaries  = desc[:binaries]
        @sdks      = desc[:sdks]
        @supports  = desc[:supports]
      end

      def self.find(name_or_version)
        return find_by_name(name_or_version) if NAMES.include?(name_or_version)
        return find_by_version(name_or_version) if VERSIONS.include?(name_or_version)
      end

      def self.find_by_name(name)
        find_by_version(NAME_TO_VERSION[name])
      end

      def self.find_by_version(version)
        # Try to find an install via the registry.
        name, root, languages = self._find_via_registry(version)
        return nil if root.nil?

        # We might be using standalone editions, so we need to verify that we
        # can compile C/C++.
        supports = [:c, :cpp].select {|language| languages.include? language}
        # TODO(mtwilliams): Support C/C++ and/or C# projects.
        return nil unless [:c, :cpp].all? {|language| supports.include? language}

        includes, libraries, binaries =
          case version.to_f
            when 8.0..11.0
              # TODO(mtwilliams): Check if x86_64 support exists.
              includes  = [File.join(root, 'VC', 'include')]
              libraries = {:x86    => [File.join(root, 'VC', 'lib')],
                           :x86_64 => []}
              binaries  = {:x86    => [File.join(root, 'VC', 'bin')],
                           :x86_64 => []}
              supports << :x86
              [includes, libraries, binaries]
            when 12.0..14.0
              # TODO(mtwilliams): Handle 64-bit and ARM compiler host variants.
              includes  = [File.join(root, 'VC', 'include')]
              libraries = {:x86    => [File.join(root, 'VC', 'lib')],
                           :x86_64 => [File.join(root, 'VC', 'lib', 'amd64')],
                           :arm    => [File.join(root, 'VC', 'lib', 'arm')]}
              binaries  = {:x86    => [File.join(root, 'VC', 'bin')],
                           :x86_64 => [File.join(root, 'VC', 'bin', 'x86_amd64')],
                           :arm    => [File.join(root, 'VC', 'bin', 'x86_arm')]}
              supports << :x86
              supports << :x86_64
              supports << :arm
              [includes, libraries, binaries]
            else
              raise "Wha-?"
            end

        # TODO(mtwilliams): Handle other SDKs, like Xbox.
        sdks = (VERSION_TO_SDKS[version][:windows].map do |version|
                  Windows::SDK.find(version)
                end).compact

        # TODO(mtwilliams): Cache.
        VisualStudio::Install.new(name: name,
                                  version: version,
                                  root: root,
                                  includes: includes,
                                  libraries: libraries,
                                  binaries: binaries,
                                  sdks: {windows: sdks},
                                  supports: supports)
      end

      private
        def self._find_via_registry(version)
          c_and_cpp = self._find_product_via_registry('VC', version)
          csharp    = self._find_product_via_registry('VC#', version)
          return nil if [c_and_cpp, csharp].all?{|root| root.nil?}

          name = VERSION_TO_NAME[version]
          root = File.expand_path(File.join(c_and_cpp || csharp, '..'))
          languages = []
           languages << :c if c_and_cpp
           languages << :cpp if c_and_cpp
           languages << :csharp if csharp

          [name, root, languages]
        end

        def self._find_product_via_registry(product, version)
          # We try to find a full version of Visual Studio. If we can't, then
          # we look for standalone verions, i.e. Express Editions.
          keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\#{version}\\Setup\\#{product}",
                  "SOFTWARE\\Microsoft\\VisualStudio\\#{version}\\Setup\\#{product}",
                  "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\#{version}\\Setup\\#{product}",
                  "SOFTWARE\\Microsoft\\VCExpress\\#{version}\\Setup\\#{product}"]
          installs = keys.map do |key|
            begin
              require 'win32/registry'
              return File.expand_path(::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)['ProductDir']).to_s
            rescue
            end
          end
          installs.compact.first
        end
    end

    def self.installed?(name_or_version)
      !!(find(name_or_version))
    end
  end
end
