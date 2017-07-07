# frozen_string_literal: true
module Valkyrie
  class FileRepository
    class_attribute :repositories
    self.repositories = {}
    def self.register(repository, short_name)
      repositories[short_name] = repository
    end

    def self.unregister(short_name)
      repositories.delete(short_name)
    end

    def self.find(short_name)
      repositories[short_name]
    end

    def self.find_by(id:)
      repositories.values.find do |repository|
        repository.handles?(id: id)
      end.find_by(id: id)
    end

    class DiskRepository
      attr_reader :base_path
      def initialize(base_path:)
        @base_path = Pathname.new(base_path.to_s)
      end

      def upload(file:, model: nil)
        new_path = base_path.join(model.try(:id).to_s, file.original_filename)
        FileUtils.mkdir_p(new_path.parent)
        FileUtils.mv(file.path, new_path)
        find_by(id: Valkyrie::ID.new("diskrepository://#{new_path}"))
      end

      def handles?(id:)
        id.to_s.start_with?("diskrepository://")
      end

      def file_path(id)
        id.to_s.gsub(/^diskrepository:\/\//, '')
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
