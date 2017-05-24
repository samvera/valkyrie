# frozen_string_literal: true
module Valkyrie
  class Adapter
    class_attribute :adapters
    self.adapters = {}
    class << self
      def register(adapter, short_name)
        adapters[short_name.to_sym] = adapter
      end

      def find(short_name)
        adapters[short_name.to_sym]
      end
    end
  end
end
