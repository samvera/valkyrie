# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindByIdQuery
    attr_reader :id, :connection, :resource_factory
    def initialize(id, connection:, resource_factory:)
      @id = id
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
      resource_factory.to_resource(resource)
    end

    def id
      "id-#{@id}"
    end

    def resource
      connection.get("select", params: { q: "id:\"#{id}\"", fl: "*", rows: 1 })["response"]["docs"].first
    end
  end
end
