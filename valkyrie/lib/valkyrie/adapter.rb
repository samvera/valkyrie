# frozen_string_literal: true
module Valkyrie
  class Adapter
    class_attribute :adapters
    self.adapters = {}
    class << self
      # Register an adapter by a short name.
      # @param adapter [Valkyrie::Adapter] Adapter to register.
      # @param short_name [Symbol] Name to register it under.
      def register(adapter, short_name)
        adapters[short_name.to_sym] = adapter
      end

      # Find an adapter by its short name.
      # @param short_name [Symbol]
      # @return [Valkyrie::Adapter]
      def find(short_name)
        adapters[short_name.to_sym]
      end
    end
  end
end
