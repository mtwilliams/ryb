require 'rbconfig'
require 'delegate'
require 'hashie'
require 'pour'
require 'visual_studio'
require 'ninja'

module Ryb
  require 'ryb/gem'

  require 'ryb/helpers/defaults'
  require 'ryb/helpers/pretty_string'

  require 'ryb/name'
  require 'ryb/paths'
  require 'ryb/languages'
  require 'ryb/source_file'

  require 'ryb/environment'
  require 'ryb/flags'
  require 'ryb/preprocessor'
  require 'ryb/code'
  require 'ryb/dependency'
  require 'ryb/dependencies'
  require 'ryb/configuration'
  require 'ryb/configurations'
  require 'ryb/product'
  require 'ryb/project'

  require 'ryb/dsl'

  require 'rybfile'
  require 'rybfile/walker'

  require 'ryb/visual_studio'
  require 'ryb/ninja'

  require 'ryb/cli'
end
