# frozen_string_literal: true
module Valkyrie::Persistence
  class BufferedPersister
    attr_reader :persister, :buffer_class
    delegate :adapter, to: :persister
    def initialize(persister, buffer_class: Valkyrie::Persistence::DeleteTrackingBuffer)
      @persister = persister
      @buffer_class = buffer_class
    end

    def save(resource:)
      persister.save(resource: resource)
    end

    def save_all(resources:)
      persister.save_all(resources: resources)
    end

    def delete(resource:)
      persister.delete(resource: resource)
    end

    def wipe!
      persister.wipe!
    end

    def with_buffer
      memory_buffer = buffer_class.new
      yield [Valkyrie::Persistence::CompositePersister.new(self, memory_buffer.persister), memory_buffer]
    end
  end
end
