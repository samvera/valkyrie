# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class ResourceFactory
    require 'valkyrie/persistence/solr/orm_converter'
    require 'valkyrie/persistence/solr/model_converter'
    attr_reader :resource_indexer
    def initialize(resource_indexer:)
      @resource_indexer = resource_indexer
    end

    # @param solr_document [Hash] The solr document in a hash to convert to a
    #   resource.
    # @return [Valkyrie::Resource]
    def to_resource(solr_document)
      ORMConverter.new(solr_document).convert!
    end

    # @param resource [Valkyrie::Resource] The resource to convert to a solr hash.
    # @return [Hash] The solr document represented as a hash.
    def from_resource(resource)
      Valkyrie::Persistence::Solr::ModelConverter.new(resource, resource_factory: self).convert!
    end
  end
end
