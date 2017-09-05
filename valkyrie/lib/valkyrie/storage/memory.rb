# frozen_string_literal: true
module Valkyrie::Storage
  class Memory
    attr_reader :cache
    def initialize
      @cache = {}
    end

    # @param file [IO]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, resource: nil)
      identifier = Valkyrie::ID.new("memory://#{resource.id}")
      cache[identifier] = Valkyrie::StorageAdapter::File.new(id: identifier, io: file)
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    def find_by(id:)
      return unless handles?(id: id) && cache[id]
      cache[id]
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("memory://")
    end

    # @param id [Valkyre::ID]
    # @param digests [Digest]
    # @return [Digest]
    def checksum(id:, digests:)
      io = cache[id].io
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
    def valid?(id:, size:, digests:)
      return false unless handles?(id: id)
      return false if size && cache[id].size.to_i != size.to_i
      calc_digests = checksum(id: id, digests: digests.keys.map { |alg| Digest(alg.upcase).new })
      return false unless digests.values == calc_digests

      true
    end
  end
end
