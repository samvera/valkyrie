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
      repository(model).persist
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(model:)
      repository(model).delete
    end

    def repository(model)
      Valkyrie::Persistence::Solr::Repository.new(model: model, connection: connection, resource_factory: resource_factory)
    end
  end
end
