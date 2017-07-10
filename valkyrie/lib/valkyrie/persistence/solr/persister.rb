# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/repository'
  class Persister
    attr_reader :adapter
    delegate :connection, :resource_factory, to: :adapter
    # @param adapter [Valkyrie::Persistence::Solr::Adapter] The adapter with the
    #   configured solr connection.
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(model:)
      repository([model]).persist.first
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(models:)
      repository(models).persist
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(model:)
      repository([model]).delete.first
    end

    def repository(models)
      Valkyrie::Persistence::Solr::Repository.new(models: models, connection: connection, resource_factory: resource_factory)
    end
  end
end
