# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/repository'
  class Persister
    attr_reader :adapter
    delegate :connection, :resource_factory, to: :adapter
    # @param adapter [Valkyrie::Persistence::Solr::MetadataAdapter] The adapter with the
    #   configured solr connection.
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
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

    def repository(resources)
      Valkyrie::Persistence::Solr::Repository.new(resources: resources, connection: connection, resource_factory: resource_factory)
    end
  end
end
