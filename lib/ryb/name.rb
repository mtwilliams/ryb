module Ryb
  class Name < Ryb::Helpers::PrettyString
    def canonicalize
      self.to_s
    end
  end
end
