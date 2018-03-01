# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  # Responsible for returning a single resource identified by an ID.
  class FindByIdQuery
    attr_reader :connection, :resource_factory
    attr_writer :id
    def initialize(id, connection:, resource_factory:)
      @id = id
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
      resource_factory.to_resource(object: resource)
    end

    def id
      @id.to_s
    end

    def resource
      connection.get("select", params: { q: "id:\"#{id}\"", fl: "*", rows: 1 })["response"]["docs"].first
    end
  end
end
