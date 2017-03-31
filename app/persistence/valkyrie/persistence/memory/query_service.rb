# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class QueryService
    attr_reader :adapter
    delegate :cache, to: :adapter
    def initialize(adapter)
      @adapter = adapter
    end

    def find_by_id(id:)
      cache[id] || raise(::Persister::ObjectNotFoundError)
    end

    def find_all
      cache.values
    end

    def find_members(*opts)
      model = opts.fetch(:model) if opts[0].respond_to?(:fetch)
      model = opts[0]
      model.member_ids.map do |id|
        find_by_id(id: id)
      end
    end
  end
end
