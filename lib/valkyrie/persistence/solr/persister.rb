# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/repository'
  # Persister for Solr MetadataAdapter.
  #
  # Most methods are delegated to {Valkyrie::Persistence::Solr::Repository}
  class Persister
    attr_reader :adapter
    delegate :connection, :resource_factory, :write_only?, to: :adapter

    # @param adapter [Valkyrie::Persistence::Solr::MetadataAdapter] The adapter with the
    #   configured solr connection.
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(resource:)
      if write_only?
        repository([resource]).persist
      else
        repository([resource]).persist.first
      end
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      repository(resources).persist
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(resource:)
      repository([resource]).delete.first
    end

    # (see Valkyrie::Persistence::Memory::Persister#wipe!)
    def wipe!
      connection.delete_by_query("*:*")
      connection.commit
    end

    # Constructs a Solr::Repository object for a set of Valkyrie Resources
    # @param [Array<Valkyrie::Resource>] resources
    # @return [Valkyrie::Persistence::Solr::Repository]
    def repository(resources)
      Valkyrie::Persistence::Solr::Repository.new(resources: resources, persister: self)
    end
  end
end
