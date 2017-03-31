# frozen_string_literal: true
module Penguin::Persistence
  module Postgres
    def persister
      Penguin::Persistence::Postgres::Persister
    end

    def query_service
      Penguin::Persistence::Postgres::QueryService
    end

    def resource_factory
      Penguin::Persistence::Postgres::ResourceFactory
    end

    module_function :persister, :query_service, :resource_factory
  end
end
