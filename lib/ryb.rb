require 'rbconfig'
require 'delegate'
require 'hashie'
require 'pour'
require 'visual_studio'
require 'ninja'

module Ryb
  require_relative 'ryb/gem'

  require_relative 'ryb/helpers/defaults'
  require_relative 'ryb/helpers/pretty_string'

  require_relative 'ryb/name'
  require_relative 'ryb/paths'
  require_relative 'ryb/languages'
  require_relative 'ryb/source_file'

  require_relative 'ryb/environment'
  require_relative 'ryb/flags'
  require_relative 'ryb/preprocessor'
  require_relative 'ryb/code'
  require_relative 'ryb/dependency'
  require_relative 'ryb/dependencies'
  require_relative 'ryb/configuration'
  require_relative 'ryb/configurations'
  require_relative 'ryb/product'
  require_relative 'ryb/project'

  require_relative 'ryb/dsl'

  require_relative 'rybfile'
  require_relative 'rybfile/walker'

  require_relative 'ryb/visual_studio'
  require_relative 'ryb/ninja'

  require_relative 'ryb/cli'
end
