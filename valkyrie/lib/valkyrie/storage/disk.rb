# frozen_string_literal: true
module Valkyrie::Storage
  class Disk
    attr_reader :base_path, :path_generator, :file_mover
    def initialize(base_path:, path_generator: BucketedStorage, file_mover: FileUtils.method(:mv))
      @base_path = Pathname.new(base_path.to_s)
      @path_generator = path_generator.new(base_path: base_path)
      @file_mover = file_mover
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, original_filename:, resource: nil, previous: nil)
      new_path = path_generator.generate(resource: resource, file: file, original_filename: original_filename, previous: previous)
      result = FileUtils.mkdir_p(new_path.parent)
      puts "New #{result} - #{new_path.parent}"

      file_mover.call(file.path, new_path)
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
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      Valkyrie::StorageAdapter::File.new(id: Valkyrie::ID.new(id.to_s), io: ::File.open(file_path(id), 'rb'))
    rescue Errno::ENOENT
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      path = file_path(id)
      FileUtils.rm_rf(path) if File.exist?(path)
    end

    class BucketedStorage
      attr_reader :base_path
      def initialize(base_path:)
        @base_path = base_path
      end

      def generate(resource:, file:, original_filename:, previous:)
        raise ArgumentError, "original_filename must be provided" unless original_filename
        bucketed = Pathname.new(base_path).join(*bucketed_path(resource.id))
        versioned = versioned_path(base: bucketed, previous: previous)
        versioned.join(original_filename)
      end

      def bucketed_path(id)
        cleaned_id = id.to_s.delete("-")
        cleaned_id[0..5].chars.each_slice(2).map(&:join) + [cleaned_id]
      end

      # Look for other directories that look like integers in the base directory.
      # Return a new path with the next highest integer.
      # TODO: this must have a lock so that two threads/processes don't issue the same id.
      def versioned_path(base:, previous:)
        return base + '0' unless base.exist?
        directories = base.children.select { |child| child.directory? }
        n = if directories.empty?
              0
            else
              last_version(directories) + 1
            end
        base + n.to_s
      end

      def last_version(directories)
        directories.map {|c| c.basename.to_s }
          .select { |c| /^\d+$/.match?(c) }
          .map { |c| c.to_i}
          .max
      end
    end
  end
end
