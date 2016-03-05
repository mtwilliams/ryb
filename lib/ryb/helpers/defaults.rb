module Ryb
  module Helpers
    module Defaults
      def self.targets
        @@targets = begin
          case RbConfig::CONFIG["host_os"]
            when /mswin|windows|mingw|cygwin/i
              ['windows']
            when /darwin/i
              ['macosx']
            when /linux/i
              ['linux']
            end
        end
      end

      def self.toolchains
        @@toolchains ||= {
          'windows' => 'msvc',
          'macosx' => 'clang+llvm',
          'linux' => 'gcc'
        }
      end
    end
  end
end
