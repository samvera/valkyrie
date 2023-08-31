# frozen_string_literal: true
module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data in memory
  #
  # @note this adapter is used primarily for testing, and is not recommended
  #   in cases where you want to preserve real data
  class Memory
    attr_reader :cache
    def initialize
      @cache = {}
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param _extra_arguments [Hash] additional arguments which may be passed to other adapters
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource: nil, **_extra_arguments)
      identifier = Valkyrie::ID.new("memory://#{resource.id}")
      cache[identifier] = Valkyrie::StorageAdapter::StreamFile.new(id: identifier, io: file)
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param previous_version_id [Valkyrie::ID]
    # @param _extra_arguments [Hash] additional arguments which may be passed to
    #   other adapters.
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload_version(file:, original_filename:, previous_version_id:)
      # Get previous file and add a UUID to the end of it.
      previous_file = find_by(id: previous_version_id)
      previous_file = previous_file.new(id: Valkyrie::ID.new("#{previous_version_id}##{SecureRandom.uuid}"))
      cache[previous_file.id] = previous_file
      cache["#{previous_version_id}_versions"] ||= []
      cache["#{previous_version_id}_versions"] = [previous_file] + cache["#{previous_version_id}_versions"]
      cache[previous_version_id] = Valkyrie::StorageAdapter::StreamFile.new(id: previous_version_id, io: file)
    end

    # @param id [Valkyrie::ID]
    # @return [Array<Valkyrie::StorageAdapter::StreamFile>]
    def find_versions(id:)
      [find_by(id: id)] + cache.fetch("#{id}_versions", [])
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

    # @param feature [Symbol] Feature to test for.
    # @return [Boolean] true if the adapter supports the given feature
    def supports?(feature)
      case feature
      when :versions
        true
      else
        false
      end
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      cache.delete(id)
      nil
    end
  end
end
