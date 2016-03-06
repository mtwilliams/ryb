module Ryb
  class SourceFile
    attr_reader :path
    attr_reader :language
    attr_reader :inconsequential

    def initialize(path, opts={})
      @path = path
      @language = opts[:language] || SourceFile.language_from_path(path)
      @inconsequential = SourceFile.inconsequential?(@path)

      # TODO(mtwilliams): Use Ryb::UnsupportedLanguage.
      unless Ryb::Languages.supported?(@language)
        raise "..." unless @inconsequential
      end
    end

    alias :eql? :==
    def ==(other)
      self.path == other.path
    end

    def self.c(path)
      SourceFile.new(path, :language => :c)
    end

    def self.cpp(path)
      SourceFile.new(path, :language => :cpp)
    end

    def self.csharp(path)
      SourceFile.new(path, :language => :csharp)
    end

    def self.language_from_path(path)
      if ext = File.extname(path)[1..-1]
        self.language_from_extension(ext)
      end
    end

    EXTENSIONS_TO_LANGUAGE = {%w{h}                 => :c,
                              %w{c}                 => :c,
                              %w{hh hpp hxx h++}    => :cpp,
                              %w{cc cpp cxx c++}    => :cpp,
                              %w{cs}                => :csharp}

    def self.language_from_extension(ext)
      EXTENSIONS_TO_LANGUAGE.each do |extensions, language|
        return language if extensions.include?(ext)
      end
      :unknown
    end

    INCONSEQUENTIAL = %w{h hpp hxx h++ inl}

    def self.inconsequential?(path)
      if ext = File.extname(path)[1..-1]
        INCONSEQUENTIAL.include? ext
      end
    end
  end
end
