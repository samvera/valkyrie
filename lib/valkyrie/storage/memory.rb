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
      version_id = URI(id.to_s).path.to_i
      base_path = to_id(resource_id: URI(id.to_s).host)
      result = cache.fetch(base_path) { raise Valkyrie::StorageAdapter::FileNotFound }[version_id]
      return result if result
      raise Valkyrie::StorageAdapter::FileNotFound
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

    # @param id [Valkyrie::ID]
    def versions(id:)
      uri = URI(id.to_s)
      # This already is a version, so just return itself.
      return [id] if uri.path.present?
      resource_id = uri.host
      cache[to_id(resource_id: resource_id)].keys.map do |v|
        Valkyrie::ID.new("memory://#{resource_id}/#{v}")
      end
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
              cache[id].keys.count
            else
              0
            end
        { resource_id: resource.id, version: n }
      end

      def to_id(key)
        Valkyrie::ID.new("memory://#{key[:resource_id]}")
      end
  end
end
