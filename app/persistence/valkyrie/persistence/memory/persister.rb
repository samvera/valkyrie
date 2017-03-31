# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class Persister
    attr_reader :adapter
    delegate :cache, to: :adapter
    def initialize(adapter)
      @adapter = adapter
    end

    def save(model:)
      generate_id(model) if model.id.blank?
      cache[model.id] = inner_model(model)
    end

    def delete(model)
      cache.delete(model.id)
    end

    private

      def inner_model(model)
        if model.respond_to?(:model)
          model.model
        else
          model
        end
      end

      def generate_id(model)
        inner_model(model).id = SecureRandom.uuid
      end
  end
end
