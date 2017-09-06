# frozen_string_literal: true
module Valkyrie
  class StorageAdapter
    class_attribute :storage_adapters
    self.storage_adapters = {}
    class << self
      # Add a storage adapter to the registry under the provided short name
      # @param storage_adapter [Valkyrie::StorageAdapter]
      # @param short_name [Symbol]
      # @return [void]
      def register(storage_adapter, short_name)
        storage_adapters[short_name] = storage_adapter
      end

      # @param short_name [Symbol]
      # @return [void]
      def unregister(short_name)
        storage_adapters.delete(short_name)
      end

      # Find the adapter associated with the provided short name
      # @param short_name [Symbol]
      # @return [Valkyrie::StorageAdapter]
      def find(short_name)
        storage_adapters[short_name]
      end

      # Search through all registered storage adapters until it finds one that
      # can handle the passed in identifier.  The call find_by on that adapter
      # with the given identifier.
      # @param id [Valkyrie::ID]
      # @return [Valkyrie::StorageAdapter::File]
      def find_by(id:)
        storage_adapters.values.find do |storage_adapter|
          storage_adapter.handles?(id: id)
        end.find_by(id: id)
      end
    end

    class File < Dry::Struct
      attribute :id, Valkyrie::Types::Any
      attribute :io, Valkyrie::Types::Any
      delegate :size, :read, :rewind, to: :io
      def stream
        io
      end

      # @param id [Valkyre::ID]
      # @param digests [Array<Digest>]
      # @return [Array<Digest>]
      def checksum(digests:)
        io.rewind
        while (chunk = io.read(4096))
          digests.each { |digest| digest.update(chunk) }
        end

        digests.map(&:to_s)
      end

      # @param id [Valkyre::ID]
      # @param size [Integer]
      # @param digests [Array<Digest>]
      # @return [Boolean]
      def valid?(size:, digests:)
        return false if size && io.size.to_i != size.to_i
        calc_digests = checksum(digests: digests.keys.map { |alg| Digest(alg.upcase).new })
        return false unless digests.values == calc_digests

        true
      end
    end
  end
end
