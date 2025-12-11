# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindInBatchesQuery
    attr_reader :connection, :resource_factory, :start, :batch_size, :except_models

    # @param [RSolr::Client] connection
    # @param [ResourceFactory] resource_factory
    def initialize(connection:, resource_factory:, start:, batch_size:, except_models:)
      Valkyrie.logger.warn("You are trying to query from Solr in batches larger than 1_000, this may cause issues for large Solr documents") if batch_size > 1_000
      @connection = connection
      @resource_factory = resource_factory
      @start = start
      @batch_size = batch_size
      @except_models = except_models
    end

    # Queries for all Documents in the Solr index in batches
    # For each Document, it yields the Valkyrie Resource which was converted from it
    # @yield [Array<Valkyrie::Resource>] batch Yields each batch of Valkyrie Resources
    # @return [void]
    def run
      docs = Paginator.new(start: start, batch_size: batch_size)
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]

        resources = docs.map do |doc|
          resource_factory.to_resource(object: doc)
        end

        yield resources unless resources.empty?
      end
    end

    # Generates the Solr query for retrieving all Documents in the index in batches
    # If a model is specified for the query, it is scoped to that Valkyrie resource type
    # @return [String]
    def query
      if except_models.empty?
        "*:*"
      else
        excluded_types = except_models.map { |model| "\"#{model}\"" }.join(" OR ")
        "*:* AND NOT internal_resource_ssim:(#{excluded_types})"
      end
    end
  end
end
