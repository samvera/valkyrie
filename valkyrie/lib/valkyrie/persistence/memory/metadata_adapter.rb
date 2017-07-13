# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class MetadataAdapter
    attr_writer :cache

    # @return [Valkyrie::Persistence::Memory::Persister] A memory persister for
    #   this adapter.
    def persister
      Valkyrie::Persistence::Memory::Persister.new(self)
    end

    # @return [Valkyrie::Persistence::Memory::QueryService] A query service for
    #   this adapter.
    def query_service
      Valkyrie::Persistence::Memory::QueryService.new(adapter: self)
    end

    def cache
      @cache ||= {}
    end
  end
end
