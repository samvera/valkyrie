# frozen_string_literal: true
module Valkyrie::Storage
  class Memory
    attr_reader :cache
    def initialize
      @cache = {}
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param previous [Valkyrie::StorageAdapter::StreamFile]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource:, previous: nil)
      identifier = next_version_identifier(resource: resource, previous: previous)
      cache[identifier] = Valkyrie::StorageAdapter::StreamFile.new(id: identifier, io: file)
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      raise Valkyrie::StorageAdapter::FileNotFound unless cache[id]
      cache[id]
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("memory://")
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      cache.delete(id)
      nil
    end

    private

    def next_version_identifier(resource:, previous:)
      n = if previous.nil?
            0
          else
            previous.id.to_s.split('/').last.to_i + 1
          end
      Valkyrie::ID.new("memory://#{resource.id}/#{n}")
    end
  end
end
