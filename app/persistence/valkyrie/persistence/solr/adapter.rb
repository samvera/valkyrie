# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Adapter
    attr_reader :connection
    def initialize(connection:)
      @connection = connection
    end

    def persister
      Valkyrie::Persistence::Solr::Persister.new(adapter: self)
    end

    def query_service
      Valkyrie::Persistence::Solr::QueryService
    end

    def resource_factory
      Valkyrie::Persistence::Solr::ResourceFactory
    end
  end
end
