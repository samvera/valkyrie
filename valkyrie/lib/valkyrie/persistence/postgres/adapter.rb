# frozen_string_literal: true
require 'valkyrie/persistence/postgres/persister'
require 'valkyrie/persistence/postgres/query_service'
module Valkyrie::Persistence::Postgres
  class Adapter
    def self.persister
      Valkyrie::Persistence::Postgres::Persister
    end

    def self.query_service
      Valkyrie::Persistence::Postgres::QueryService
    end
  end
end
