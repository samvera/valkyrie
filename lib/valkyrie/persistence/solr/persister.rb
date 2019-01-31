# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/repository'
  # Persister for Solr MetadataAdapter.
  #
  # Most methods are delegated to {Valkyrie::Persistence::Solr::Repository}
  class Persister
    attr_reader :adapter
    delegate :connection, :resource_factory, to: :adapter

    # @param adapter [Valkyrie::Persistence::Solr::MetadataAdapter] The adapter with the
    #   configured solr connection.
    def initialize(adapter:)
      @adapter = adapter
    end

    # Persists a Valkyrie Resource into a Solr index
    # @note Fields are saved using Solr's dynamic fields functionality.
    #   If the text has length > 1000, it is stored as *_tsim
    #   otherwise it's stored as *_tsim, *_ssim, and *_tesim
    #   e.g., a field called 'title' would be stored as 3 solr fields:
    #     'title_tsim'
    #     'title_ssim'
    #     'title_tesim'
    # @param [Valkyrie::Resource] resource
    # @param [TrueClass || FalseClass] force This flag is a NOOP
    # @return [Valkyrie::Resource] the persisted resource
    def save(resource:, force: nil)
      repository([resource]).persist.first
    end

    # Persists a set of Valkyrie Resources into a Solr index
    # @param [Array<Valkyrie::Resource>] resources
    # @param [TrueClass || FalseClass] force This flag is a NOOP
    # @return [Valkyrie::Resource] the set of persisted resources
    def save_all(resources:, force: nil)
      repository(resources).persist
    end

    # Deletes a Valkyrie Resource persisted into a Solr index
    # @param [Valkyrie::Resource] resource
    # @return [Valkyrie::Resource] the deleted resource
    def delete(resource:)
      repository([resource]).delete.first
    end

    # Delete the Solr index of all Documents
    def wipe!
      connection.delete_by_query("*:*")
      connection.commit
    end

    # Constructs a Solr::Repository object for a set of Valkyrie Resources
    # @param [Array<Valkyrie::Resource>] resources
    # @return [Valkyrie::Persistence::Solr::Repository]
    def repository(resources)
      Valkyrie::Persistence::Solr::Repository.new(resources: resources, connection: connection, resource_factory: resource_factory)
    end
  end
end
