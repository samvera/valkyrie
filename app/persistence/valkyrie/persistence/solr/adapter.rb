# frozen_string_literal: true
module Penguin::Persistence::Solr
  class Adapter
    attr_reader :connection, :resource_indexer
    def initialize(connection:, resource_indexer: NullIndexer)
      @connection = connection
      @resource_indexer = resource_indexer
    end

    def persister
      Penguin::Persistence::Solr::Persister.new(adapter: self)
    end

    def query_service
      Penguin::Persistence::Solr::QueryService.new(connection: connection, resource_factory: resource_factory)
    end

    def resource_factory
      Penguin::Persistence::Solr::ResourceFactory.new(resource_indexer: resource_indexer)
    end

    class NullIndexer
      def initialize(_); end

      def to_solr
        {}
      end
    end
  end
end
