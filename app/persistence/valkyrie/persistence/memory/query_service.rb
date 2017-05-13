# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class QueryService
    attr_reader :adapter
    delegate :cache, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def find_by(id:)
      cache[id] || raise(::Persister::ObjectNotFoundError)
    end

    def find_all
      cache.values
    end

    def find_members(model:)
      member_ids(model: model).map do |id|
        find_by(id: id)
      end
    end

    def find_references_by(model:, property:)
      Array.wrap(model[property]).map do |id|
        find_by(id: id)
      end
    end

    def find_parents(model:)
      cache.values.select do |record|
        member_ids(model: record).include?(model.id)
      end
    end

    def member_ids(model:)
      model.member_ids || []
    end
  end
end
