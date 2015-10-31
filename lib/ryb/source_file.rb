module Ryb
  class SourceFile
    attr_reader :path
    attr_reader :language

    def initialize(path, opts={})
      super(path)
      @path = path
      @language = opts[:language] || SourceFile.language_from_path(path)
      # TODO(mtwilliams): Use Ryb::UnsupportedLanguage.
      raise "..." unless Ryb::Languages.supported? @language
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
      if ext = File.extname(path_or_ext)
        self.language_from_extension(ext)
      end
    end

    EXTENSIONS_TO_LANGUAGE = {%w{c} => :c, %w{cc cpp cxx c++} => :cpp, %w{cs} => :csharp}
    def self.language_from_extension(ext)
      EXTENSIONS_TO_LANGUAGE.each do |extensions, language|
        return language if extensions.include?(ext)
      end
    end
  end
end
