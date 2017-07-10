# frozen_string_literal: true
module Valkyrie::Persistence
  ##
  # Wrap up multiple persisters under a common interface, to transparently
  #   persist to multiple places at once.
  class CompositePersister
    attr_reader :persisters
    def initialize(*persisters)
      @persisters = persisters
    end

    def adapter
      persisters.first.adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(model:)
      persisters.inject(model) { |m, persister| persister.save(model: m) }
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(models:)
      models.map do |model|
        save(model: model)
      end
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(model:)
      persisters.inject(model) { |m, persister| persister.delete(model: m) }
    end
  end
end
