# frozen_string_literal: true
require 'rsolr'
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/persister'
  require 'valkyrie/persistence/solr/query_service'
  require 'valkyrie/persistence/solr/resource_factory'
  class MetadataAdapter
    attr_reader :connection, :resource_indexer, :commit_params
    # @param connection [RSolr::Client] The RSolr connection to index to.
    # @param resource_indexer [Class, #to_solr] An indexer which is able to
    #   receive a `resource` argument and then has an instance method `#to_solr`
    def initialize(connection:, resource_indexer: NullIndexer, commit_params: { softCommit: true })
      @connection = connection
      @resource_indexer = resource_indexer
      @commit_params = commit_params
    end

    # @return [Valkyrie::Persistence::Solr::Persister] The solr persister.
    def persister
      Valkyrie::Persistence::Solr::Persister.new(adapter: self)
    end

    # @return [Valkyrie::Persistence::Solr::QueryService] The solr query
    #   service.
    def query_service
      @query_service ||= Valkyrie::Persistence::Solr::QueryService.new(
        connection: connection,
        resource_factory: resource_factory
      )
    end

    # @return [Valkyrie::Persistence::Solr::ResourceFactory] A resource factory
    #   to convert a resource to a solr document and back.
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
