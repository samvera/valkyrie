# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindManyByIdsQuery
    attr_reader :connection, :resource_factory
    attr_accessor :ids
    def initialize(ids, connection:, resource_factory:)
      @ids = ids
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      resources.map { |solr_resource| resource_factory.to_resource(object: solr_resource) }
    end

    def resources
      id_query = ids.map { |id| "\"#{id}\"" }.join(' OR ')
      @resources ||= connection.get("select", params: { q: "id:(#{id_query})", fl: "*", defType: 'lucene', rows: 1_000_000_000 })["response"]["docs"]
    end
  end
end
