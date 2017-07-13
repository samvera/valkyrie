# frozen_string_literal: true
require 'valkyrie/persistence/postgres/persister'
require 'valkyrie/persistence/postgres/query_service'
module Valkyrie::Persistence::Postgres
  class MetadataAdapter
    # @return [Class] {Valkyrie::Persistence::Postgres::Persister}
    def persister
      Valkyrie::Persistence::Postgres::Persister
    end

    # @return [Class] {Valkyrie::Persistence::Postgres::QueryService}
    def query_service
      Valkyrie::Persistence::Postgres::QueryService
    end
  end
end
