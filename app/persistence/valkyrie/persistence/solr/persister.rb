# frozen_string_literal: true
module Penguin::Persistence::Solr
  class Persister
    attr_reader :adapter
    delegate :connection, :resource_factory, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def save(model)
      repository(model).persist
    end

    def delete(model)
      repository(model).delete
    end

    def repository(model)
      Penguin::Persistence::Solr::Repository.new(model: model, connection: connection, resource_factory: resource_factory)
    end
  end
end
