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
        FileUtils.mv(file.tempfile.path, new_path)
        File.new(id: Valkyrie::ID.new("diskrepository://#{new_path}"), repository: self)
      end

      def handles?(id:)
        id.to_s.start_with?("diskrepository://")
      end

      def find_by(id:)
        return unless handles?(id: id)
        File.new(id: Valkyrie::ID.new(id.to_s), repository: self)
      end
    end

    class Memory
      attr_reader :cache
      def initialize
        @cache = {}
      end

      def upload(file:, model: nil)
        io = StringIO.new(file.read)
        identifier = Valkyrie::ID.new("memory://#{model.id}")
        cache[identifier] = io
        File.new(id: identifier, repository: self)
      end

      def find_by(id:)
        return unless handles?(id: id) && cache[id]
        File.new(id: id, repository: self)
      end

      def handles?(id:)
        id.to_s.start_with?("memory://")
      end
    end

    class File
      attr_reader :id, :repository
      def initialize(id:, repository:)
        @id = id
        @repository = repository
      end

      def read; end
    end
  end
end
