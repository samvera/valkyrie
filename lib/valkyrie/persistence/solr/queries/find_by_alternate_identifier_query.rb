# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  # Responsible for returning a single resource identified by an ID.
  class FindByAlternateIdentifierQuery
    attr_reader :connection, :resource_factory
    attr_writer :alternate_identifier
    def initialize(alternate_identifier, connection:, resource_factory:)
      @alternate_identifier = alternate_identifier
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      raise ::Valkyrie::Persistence::ObjectNotFoundError unless resource
      resource_factory.to_resource(object: resource)
    end

    def alternate_identifier
      @alternate_identifier.to_s
    end

    def resource
      connection.get("select", params: { q: "alternate_ids_ssim:\"id-#{alternate_identifier}\"", fl: "*", rows: 1 })["response"]["docs"].first
    end
  end
end
