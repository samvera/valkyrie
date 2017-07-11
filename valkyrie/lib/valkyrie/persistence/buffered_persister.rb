# frozen_string_literal: true
module Valkyrie::Persistence
  class BufferedPersister
    attr_reader :persister, :buffer_class
    delegate :adapter, to: :persister
    def initialize(persister, buffer_class: Valkyrie::Persistence::Memory::Adapter)
      @persister = persister
      @buffer_class = buffer_class
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
      memory_buffer = buffer_class.new
      yield [Valkyrie::Persistence::CompositePersister.new(self, memory_buffer.persister), memory_buffer]
    end
  end
end
