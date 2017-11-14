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
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource:)
      key = next_version_key(resource: resource)
      put(key, Valkyrie::StorageAdapter::StreamFile.new(id: to_id(key), io: file))
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      head = head_version(id: id)
      raise Valkyrie::StorageAdapter::FileNotFound unless head
      cache[id][head]
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("memory://")
    end

    # Delete the file in memory associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      cache.delete(id)
      nil
    end

    def supports_versions?
      true
    end

    def versions(resource:)
      cache[resource.id].keys
    end

    def retrieve_version(resource:, label:)
      result = cache[resource.id][label]
      return result if result
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    private

      def put(key, value)
        id = to_id(key)
        cache[id] ||= {}
        cache[id][key[:version]] = value
      end

      def head_version(id:)
        object = cache[id]
        return unless object
        object.keys.max
      end

      def next_version_key(resource:)
        id = to_id(resource_id: resource.id)
        n = if cache.key?(id)
              cache[id].keys.count + 1
            else
              1
            end
        { resource_id: resource.id, version: "version#{n}" }
      end

      def to_id(key)
        Valkyrie::ID.new("memory://#{key[:resource_id]}")
      end
  end
end
