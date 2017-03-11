# frozen_string_literal: true
module Valkyrie::Persistence
  module Postgres
    def persister
      Valkyrie::Persistence::Postgres::Persister
    end

    def query_service
      Valkyrie::Persistence::Postgres::QueryService
    end

    def resource_factory
      Valkyrie::Persistence::Postgres::ResourceFactory
    end

    module_function :persister, :query_service, :resource_factory
  end
end
