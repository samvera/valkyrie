# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class QueryService
    attr_reader :connection
    def initialize(connection:)
      @connection = connection
    end

    def find_by_id(id)
      Valkyrie::Persistence::Solr::Queries::FindByIdQuery.new(id, connection: connection).run
    end
  end
end
