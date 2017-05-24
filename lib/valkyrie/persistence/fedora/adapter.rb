# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Adapter
    def self.persister
      Valkyrie::Persistence::Fedora::Persister
    end

    def self.query_service
      Valkyrie::Persistence::Fedora::QueryService
    end
  end
end
