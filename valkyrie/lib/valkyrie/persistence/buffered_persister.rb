# frozen_string_literal: true
module Valkyrie::Persistence
  class BufferedPersister
    attr_reader :persister
    delegate :adapter, to: :persister
    def initialize(persister)
      @persister = persister
    end

    def save(model:)
      persister.save(model: model)
    end

    def save_all(models:)
      persister.save_all(models: models)
    end

    def delete(model:)
      persister.delete(model: model)
    end

    def with_buffer
      memory_buffer = Valkyrie::Persistence::Memory::Adapter.new
      yield [Valkyrie::Persistence::CompositePersister.new(self, memory_buffer.persister), memory_buffer]
    end
  end
end
