module Ryb
  class Name < Helpers::PrettyString
    def canonicalize
      self.to_s
    end
  end
end
