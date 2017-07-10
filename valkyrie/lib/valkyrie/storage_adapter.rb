# frozen_string_literal: true
module Valkyrie
  class StorageAdapter
    class_attribute :storage_adapters
    self.storage_adapters = {}
    def self.register(storage_adapter, short_name)
      storage_adapters[short_name] = storage_adapter
    end

    def self.unregister(short_name)
      storage_adapters.delete(short_name)
    end

    def self.find(short_name)
      storage_adapters[short_name]
    end

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

      def upload(file:, model: nil)
        new_path = base_path.join(model.try(:id).to_s, file.original_filename)
        FileUtils.mkdir_p(new_path.parent)
        FileUtils.mv(file.path, new_path)
        find_by(id: Valkyrie::ID.new("disk://#{new_path}"))
      end

      def handles?(id:)
        id.to_s.start_with?("disk://")
      end

      def file_path(id)
        id.to_s.gsub(/^disk:\/\//, '')
      end

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

      def upload(file:, model: nil)
        identifier = Valkyrie::ID.new("memory://#{model.id}")
        cache[identifier] = File.new(id: identifier, io: file)
      end

      def find_by(id:)
        return unless handles?(id: id) && cache[id]
        cache[id]
      end

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
