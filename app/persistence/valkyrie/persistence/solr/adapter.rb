# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Adapter
    attr_reader :connection, :resource_indexer
    def initialize(connection:, resource_indexer: NullIndexer)
      @connection = connection
      @resource_indexer = resource_indexer
    end

    def persister
      Valkyrie::Persistence::Solr::Persister.new(adapter: self)
    end

    def query_service
      Valkyrie::Persistence::Solr::QueryService.new(connection: connection, resource_factory: resource_factory)
    end

    def resource_factory
      Valkyrie::Persistence::Solr::ResourceFactory.new(resource_indexer: resource_indexer)
    end

    class NullIndexer
      def initialize(_); end

      def to_solr
        {}
      end
    end
  end
end
