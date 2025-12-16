# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindInBatchesQuery
    attr_reader :connection, :resource_factory, :start, :batch_size, :except_models

    # @param [RSolr::Client] connection
    # @param [ResourceFactory] resource_factory
    def initialize(connection:, resource_factory:, start:, batch_size:, except_models:)
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
      all_ids_sorted.each_slice(batch_size) do |batch|
        solr_params = { q: '*:*', fq: "id:(#{batch.join(' OR ')})", sort: 'id asc' }
        resources = accumulate_from_solr(solr_params) { |doc| resource_factory.to_resource(object: doc) }

        yield resources.flatten unless resources.empty?
      end
    end

    private

    # All ids in the index, sorted by id so we have a deterministic return
    def all_ids_sorted
      @all_ids_sorted ||= begin
        solr_params = { q: query, sort: "id asc", fl: ['id'] }
        accumulate_from_solr(solr_params) { |doc| doc["id"] }
      end
    end

    def accumulate_from_solr(solr_params, &block)
      accumulator = []
      docs = DefaultPaginator.new
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, 'select', params: solr_params)["response"]["docs"]
        accumulator << docs.map(&block)
      end
      accumulator.flatten!
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
