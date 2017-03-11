# frozen_string_literal: true
module Valkyrie::Persistence
  module Solr
    def persister
      Valkyrie::Persistence::Solr::Persister
    end

    def query_service
      Valkyrie::Persistence::Solr::QueryService
    end

    module_function :persister, :query_service
  end
end
