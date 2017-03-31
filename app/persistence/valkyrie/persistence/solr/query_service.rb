# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class QueryService
    attr_reader :connection, :resource_factory
    def initialize(connection:, resource_factory:)
      @connection = connection
      @resource_factory = resource_factory
    end

    def find_by_id(id: nil)
      Valkyrie::Persistence::Solr::Queries::FindByIdQuery.new(id, connection: connection, resource_factory: resource_factory).run
    end
  end
end
