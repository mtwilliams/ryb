module Ryb
  module VisualStudio
    module Compiler
      STANDARD_FLAGS = [
        # Suppress the annoying startup banner.
        "/nologo",
        # Don't link after compilation.
        "/c",
        # Be vocal about shit code.
        "/W4",
        # Fuck off, RTTI.
        "/GR-",
        # Don't optimize for one architecture at the loss of another.
        "/favor:blend"
      ]

      def self.include_paths_to_flags(paths)
        [*paths].map{|path| "/I#{path}"}
      end

      def self.defines_to_flags(defines)
        return [] unless defines
        (defines.map do |name, value|
          case value
            when TrueClass
              "/D#{name}=1"
            when FalseClass
              "/D#{name}=0"
            when Integer
              "/D#{name}=#{value.to_s}"
            when String
              "/D#{name}=#{value.to_s}"
            else
              nil
            end
        end).compact
      end

      def self.treat_warnings_as_errors_to_flag(enabled)
        enabled ? %w{/WX} : []
      end

      def self.generate_debug_symbols_to_flag(enabled)
        enabled ? %w{/MDd /Fi} : %w{/MD}
      end

      def self.link_time_code_generation_to_flag(enabled)
        enabled ? %w{/WX} : []
      end

      def self.optimization_to_flags(optimization)
        case
          when :nothing
            %w{/Od /RTCsu /fp:precise /fp:except}
          when :size
            %w{/Os /fp:fast /fp:except-}
          when :speed
            %w{/Ox /fp:fast /fp:except-}
          end
      end
    end

    module Linker
      STANDARD_FLAGS = [
        # Suppress the annoying startup banner.
        "/nologo",
        # Don't create or embed a manifest file.
        "/manifest:no"
      ]

      def self.library_paths_to_flags(paths)
        [*paths].map{|path| "/LIBPATH:#{path}"}
      end

      def self.generate_debug_symbols_to_flag(enabled)
        enabled ? %w{/DEBUG} : %w{}
      end
    end
  end
end

