# frozen_string_literal: true
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata in Memory
  #  In Addition this stores an array of all deleted resources
  #
  # This is used by the Valkyrie::Persistence::BufferedPersister to
  #   buffer deletes for efficiency
  #
  # @see Valkyrie::Persistence::BufferedPersister
  #
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

      def delete(resource:)
        @deletes << resource
        super
      end

      # A buffered memory persister can save anything, it doesn't have to hold
      # a consistent internal state.
      def valid_for_save?(_)
        true
      end
    end
  end
end
