# frozen_string_literal: true
module Valkyrie::Persistence
  module Postgres
    def persister
      Valkyrie::Persistence::Postgres::Persister
    end

    def query_service
      Valkyrie::Persistence::Postgres::QueryService
    end

    module_function :persister, :query_service
  end
end
