# frozen_string_literal: true
module Valkyrie::Persistence::LDP
  class Persister
    attr_reader :adapter
    delegate :resource_factory, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def save(model:)
      orm = resource_factory.from_model(model)
      orm.save
      resource_factory.to_model(orm)
    end

    def delete(model:)
      orm = resource_factory.from_model(model)
      orm.delete
    end
  end
end
