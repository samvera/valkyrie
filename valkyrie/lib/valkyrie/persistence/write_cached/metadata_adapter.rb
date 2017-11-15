# frozen_string_literal: true
module Valkyrie::Persistence::WriteCached
  class MetadataAdapter
    # @param redis [Redis] The Redis connection to index to.
    # @param cache_prefix [String] A string to use as the ID prefix in the cache
    # @param expiration [Integer] The time (in seconds) for new writes to stay in the cache
    def initialize(primary_adapter:, cache_adapter:)
      @primary_adapter = primary_adapter
      @cache_adapter = cache_adapter
    end

    # @return [Valkyrie::Persistence::Redis::Persister] A memory persister for
    #   this adapter.
    def persister
      @persister ||= Valkyrie::Persistence::CompositePersister.new(@primary_adapter.persister, @cache_adapter.persister)
    end

    # @return [Valkyrie::Persistence::Redis::QueryService] A query service for
    #   this adapter.
    def query_service
      @query_service ||= Valkyrie::Persistence::WriteCached::QueryService.new(primary: @primary_adapter.query_service,
                                                                              cache: @cache_adapter.query_service)
    end
  end
end
