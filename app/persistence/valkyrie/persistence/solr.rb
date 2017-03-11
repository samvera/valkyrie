# frozen_string_literal: true
module Valkyrie::Persistence
  module Solr
    def persister
      Valkyrie::Persistence::Solr::Persister
    end

    def query_service
      Valkyrie::Persistence::Solr::QueryService
    end

    def resource_factory
      Valkyrie::Persistence::Solr::ResourceFactory
    end

    module_function :persister, :query_service, :resource_factory
  end
end
