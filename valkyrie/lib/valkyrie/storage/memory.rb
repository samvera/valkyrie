# frozen_string_literal: true
module Valkyrie::Storage
  class Memory
    attr_reader :cache
    def initialize
      @cache = {}
    end

    # @param file [IO]
    # @param model [Valkyrie::Model]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, model: nil)
      identifier = Valkyrie::ID.new("memory://#{model.id}")
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
  end
end
