module Ryb
  module Flags
    include Pourable

    # Prevent code that raises warnings from succesfully compiling.
    property :treat_warnings_as_errors, Typespec.boolean

    # Have the compiler generate debugging information.
    property :generate_debug_symbols, Typespec.boolean

    # Link (and optimize) code as late as possible.
    property :link_time_code_generation, Typespec.boolean

    # Optimize for size or speed... or neither.
    property :optimize, Typespec.enum[:nothing, :size, :speed]
  end
end
