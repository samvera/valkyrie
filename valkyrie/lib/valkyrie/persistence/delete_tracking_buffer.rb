# frozen_string_literal: true
module Valkyrie::Persistence
  class DeleteTrackingBuffer < Valkyrie::Persistence::Memory::MetadataAdapter
    def persister
      @persister ||= DeleteTrackingBuffer::Persister.new(self)
    end

    class Persister < Valkyrie::Persistence::Memory::Persister
      attr_reader :deletes
      def initialize(*args)
        @deletes = []
        super
      end

      def delete(model:)
        @deletes << model
        super
      end
    end
  end
end
