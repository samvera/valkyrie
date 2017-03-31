# frozen_string_literal: true
module Penguin::Persistence::Solr::Queries
  class FindByIdQuery
    attr_reader :id, :connection, :resource_factory
    def initialize(id, connection:, resource_factory:)
      @id = id
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      raise ::Persister::ObjectNotFoundError unless model
      resource_factory.to_model(model)
    end

    def model
      connection.get("select", params: { q: "id:#{id}", fl: "*", rows: 1 })["response"]["docs"].first
    end
  end
end
