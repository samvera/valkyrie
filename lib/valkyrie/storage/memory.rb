# frozen_string_literal: true
module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data in memory
  #
  # @note this adapter is used primarily for testing, and is not recommended
  #   in cases where you want to preserve real data
  class Memory
    attr_reader :cache
    PROTOCOL = 'memory://'

    def initialize
      @cache = {}
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param _extra_arguments [Hash] additional arguments which may be passed to other adapters
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource: nil, **_extra_arguments)
      identifier = Valkyrie::ID.new("#{PROTOCOL}#{resource.id}")
      version_id = Valkyrie::ID.new("#{identifier}##{SecureRandom.uuid}")
      cache[identifier] ||= {}
      cache[identifier][:current] = Valkyrie::StorageAdapter::StreamFile.new(id: identifier, io: file, version_id: version_id)
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param previous_version_id [Valkyrie::ID]
    # @param _extra_arguments [Hash] additional arguments which may be passed to
    #   other adapters.
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload_version(id:, file:)
      # Get previous file and add a UUID to the end of it.
      new_file = Valkyrie::StorageAdapter::StreamFile.new(id: id, io: file, version_id: Valkyrie::ID.new("#{id}##{SecureRandom.uuid}"))
      current_file = cache[id][:current]
      cache[id][:current] = new_file
      cache[id][:versions] ||= []
      cache[id][:versions].prepend(current_file) if current_file
      new_file
    end

    # @param id [Valkyrie::ID]
    # @return [Array<Valkyrie::StorageAdapter::StreamFile>]
    def find_versions(id:)
      return [] if cache[id].nil?
      [cache[id][:current] || nil].compact + cache[id].fetch(:versions, [])
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      no_version_id, _version = id_and_version(id)
      raise Valkyrie::StorageAdapter::FileNotFound unless cache[no_version_id]
      version =
        if id == no_version_id
          cache[id][:current]
        else
          find_versions(id: no_version_id).find do |file|
            file.version_id == id
          end
        end
      raise Valkyrie::StorageAdapter::FileNotFound unless version
      version
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    # @param feature [Symbol] Feature to test for.
    # @return [Boolean] true if the adapter supports the given feature
    def supports?(feature)
      case feature
      when :versions
        true
      when :version_deletion
        true
      else
        false
      end
    end

    def id_and_version(id)
      id, version = id.to_s.split("#")
      [Valkyrie::ID.new(id), version]
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      base_id, version = id_and_version(id)
      if version && cache[base_id][:current]&.version_id != id
        cache[base_id][:versions].reject! do |file|
          file.version_id == id
        end
      else
        cache.delete(base_id)
      end
      nil
    end
  end
end
