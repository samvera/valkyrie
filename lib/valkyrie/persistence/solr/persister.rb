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
    # @note (see Valkyrie::Persistence::Memory::Persister#initialize)
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    #
    # @note Fields are saved using Solr's dynamic fields functionality.
    #   If the text has length > 1000, it is stored as *_tsim
    #   otherwise it's stored as *_tsim, *_ssim, and *_tesim
    #   e.g., a field called 'title' would be stored as 3 solr fields:
    #     'title_tsim'
    #     'title_ssim'
    #     'title_tesim'
    def save(resource:)
      repository([resource]).persist.first
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      repository(resources).persist
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(resource:)
      repository([resource]).delete.first
    end

    def wipe!
      connection.delete_by_query("*:*")
      connection.commit
    end

    def repository(resources)
      Valkyrie::Persistence::Solr::Repository.new(resources: resources, connection: connection, resource_factory: resource_factory)
    end
  end
end
