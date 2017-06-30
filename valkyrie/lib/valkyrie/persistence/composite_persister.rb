# frozen_string_literal: true
module Valkyrie::Persistence
  class CompositePersister
    attr_reader :persisters
    def initialize(*persisters)
      @persisters = persisters
    end

    def adapter
      persisters.first.adapter
    end

    def save(model:)
      persisters.inject(model) { |m, persister| persister.save(model: m) }
    end

    def delete(model:)
      persisters.inject(model) { |m, persister| persister.delete(model: m) }
    end
  end
end
