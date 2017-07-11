# frozen_string_literal: true
module Valkyrie
  class StorageAdapter
    class_attribute :storage_adapters
    self.storage_adapters = {}

    # Add a storage adapter to the registry under the provided short name
    # @param storage_adapter [Valkyrie::StorageAdapter]
    # @param short_name [Symbol]
    # @return [void]
    def self.register(storage_adapter, short_name)
      storage_adapters[short_name] = storage_adapter
    end

    # @param short_name [Symbol]
    # @return [void]
    def self.unregister(short_name)
      storage_adapters.delete(short_name)
    end

    # Find the adapter associated with the provided short name
    # @param short_name [Symbol]
    # @return [Valkyrie::StorageAdapter]
    def self.find(short_name)
      storage_adapters[short_name]
    end

    # Search through all registered storage adapters until it finds one that
    # can handle the passed in identifier.  The call find_by on that adapter
    # with the given identifier.
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    def self.find_by(id:)
      storage_adapters.values.find do |storage_adapter|
        storage_adapter.handles?(id: id)
      end.find_by(id: id)
    end

    class Disk
      attr_reader :base_path
      def initialize(base_path:)
        @base_path = Pathname.new(base_path.to_s)
      end

      # @param file [IO]
      # @param model [Valkyrie::Model]
      # @return [Valkyrie::StorageAdapter::File]
      def upload(file:, model: nil)
        new_path = base_path.join(model.try(:id).to_s, file.original_filename)
        FileUtils.mkdir_p(new_path.parent)
        FileUtils.mv(file.path, new_path)
        find_by(id: Valkyrie::ID.new("disk://#{new_path}"))
      end

      # @param id [Valkyrie::ID]
      # @return [Boolean] true if this adapter can handle this type of identifer
      def handles?(id:)
        id.to_s.start_with?("disk://")
      end

      def file_path(id)
        id.to_s.gsub(/^disk:\/\//, '')
      end

      # Return the file associated with the given identifier
      # @param id [Valkyrie::ID]
      # @return [Valkyrie::StorageAdapter::File]
      def find_by(id:)
        return unless handles?(id: id)
        File.new(id: Valkyrie::ID.new(id.to_s), io: ::File.open(file_path(id)))
      end
    end

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
        cache[identifier] = File.new(id: identifier, io: file)
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

    class File < Dry::Struct
      attribute :id, Valkyrie::Types::Any
      attribute :io, Valkyrie::Types::Any
      delegate :size, :read, :rewind, to: :io
      def stream
        io
      end
    end
  end
end
