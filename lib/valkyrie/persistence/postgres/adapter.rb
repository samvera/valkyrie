# frozen_string_literal: true
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
