# frozen_string_literal: true
require 'redis'

module Valkyrie::Persistence::Redis
  class MetadataAdapter
    attr_accessor :cache
    attr_reader :cache_prefix, :expiration

    # @param redis [Redis] The Redis connection to index to.
    # @param cache_prefix [String] A string to use as the ID prefix in the cache
    # @param expiration [Integer] The time (in seconds) for new writes to stay in the cache
    def initialize(redis: Redis.new, cache_prefix: '_valkyrie_', expiration: 30.minutes)
      @cache_prefix = cache_prefix
      @expiration = expiration
      @cache = redis
    end

    # @return [Valkyrie::Persistence::Redis::Persister] A memory persister for
    #   this adapter.
    def persister
      Valkyrie::Persistence::Redis::Persister.new(adapter: self)
    end

    # @return [Valkyrie::Persistence::Redis::QueryService] A query service for
    #   this adapter.
    def query_service
      @query_service ||= Valkyrie::Persistence::Redis::QueryService.new(adapter: self)
    end
  end
end
