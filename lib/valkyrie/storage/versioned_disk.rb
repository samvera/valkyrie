# frozen_string_literal: true
module Valkyrie::Storage
  # The VersionedDisk adapter implements versioned storage on disk by storing
  # the timestamp of the file's creation as part of the file name
  # (v-timestamp-filename.jpg). If the
  # current file is deleted it creates a DeletionMarker, which is an empty file
  # with "deletionmarker" in the name of the file.
  class VersionedDisk
    attr_reader :base_path, :path_generator, :file_mover
    PROTOCOL = 'versiondisk://'

    def initialize(base_path:, path_generator: ::Valkyrie::Storage::Disk::BucketedStorage, file_mover: FileUtils.method(:cp))
      @base_path = Pathname.new(base_path.to_s)
      @path_generator = path_generator.new(base_path: base_path)
      @file_mover = file_mover
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param _extra_arguments [Hash] additional arguments which may be passed to other adapters
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, original_filename:, resource: nil, paused: false, **extra_arguments)
      version_timestamp = current_timestamp
      new_path = path_generator.generate(resource: resource, file: file, original_filename: "v-#{version_timestamp}-#{original_filename}")
      # If we've gone faster than milliseconds here, pause a millisecond and
      # re-call. Probably only an issue for test suites.
      return sleep(0.001) && upload(file: file, original_filename: original_filename, resource: resource, paused: true, **extra_arguments) if !paused && File.exist?(new_path)
      FileUtils.mkdir_p(new_path.parent)
      file_mover.call(file.try(:path) || file.try(:disk_path), new_path)
      find_by(id: Valkyrie::ID.new("#{protocol}#{new_path}"))
    end

    def current_timestamp
      Time.now.strftime("%s%L")
    end

    # @param id [Valkyrie::ID] ID of the Valkyrie::StorageAdapter::File to
    #   version.
    # @param file [IO]
    # @param paused [Boolean] set to true when upload_version had to pause for a
    #   millisecond to get a later timestamp. Internal only - do not set.
    def upload_version(id:, file:, paused: false)
      version_timestamp = current_timestamp
      # Get the existing version_id so we can calculate the next path from it.
      current_version_id = version_id(id)
      current_version_id = current_version_id.version_files[1] if current_version_id.deletion_marker?
      existing_path = current_version_id.file_path
      new_path = Pathname.new(existing_path.gsub(current_version_id.version, version_timestamp.to_s))
      # If we've gone faster than milliseconds here, pause a millisecond and
      # re-call.
      return sleep(0.001) && upload_version(id: id, file: file, paused: true) if !paused && File.exist?(new_path)
      FileUtils.mkdir_p(new_path.parent)
      file_mover.call(file.try(:path) || file.try(:disk_path), new_path)
      find_by(id: Valkyrie::ID.new("#{protocol}#{new_path}"))
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("#{protocol}#{base_path}")
    end

    # @param feature [Symbol] Feature to test for.
    # @return [Boolean] true if the adapter supports the given feature
    def supports?(feature)
      return true if feature == :versions || feature == :version_deletion
      false
    end

    # @return [String] identifier prefix
    def protocol
      PROTOCOL
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      version_id = version_id(id)
      raise Valkyrie::StorageAdapter::FileNotFound if version_id.nil? || version_id&.deletion_marker?
      Valkyrie::StorageAdapter::File.new(id: version_id.current_reference_id.id, io: ::Valkyrie::Storage::Disk::LazyFile.open(version_id.file_path, 'rb'), version_id: version_id.id)
    rescue Errno::ENOENT
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      id = version_id(id).resolve_current
      if id.current?
        id.version_files.each do |version_id|
          FileUtils.rm_rf(version_id.file_path)
        end
      elsif File.exist?(id.file_path)
        FileUtils.rm_rf(id.file_path)
      end
    end

    # @param id [Valkyrie::ID]
    # @return [Array<Valkyrie::StorageAdapter::File>]
    def find_versions(id:)
      version_files(id: id).select { |x| !x.to_s.include?("deletionmarker") }.map do |file|
        find_by(id: Valkyrie::ID.new("#{protocol}#{file}"))
      end
    end

    def version_files(id:)
      root = Pathname.new(file_path(id))
      id = VersionId.new(id)
      root.parent.children.select { |file| file.basename.to_s.end_with?(id.filename) }.sort.reverse
    end

    def file_path(version_id)
      version_id.to_s.gsub(/^#{Regexp.escape(protocol)}/, '')
    end

    # @return VersionId A VersionId value that's resolved a current reference,
    #   so we can access the `version_id` and current reference.
    def version_id(id)
      id = VersionId.new(id)
      return id unless id.versioned?
      id.resolve_current
    end

    # A small value class that holds a version id and methods for knowing things about it.
    # Examples of version ids in this adapter:
    #   * "versiondisk://te/st/test/v-current-filename.jpg" (never actually saved this way on disk, just used as a reference)
    #   * "versiondisk://te/st/test/v-1694195675462560794-filename.jpg" (this timestamped form would be saved on disk)
    #   * "versiondisk://te/st/test/v-1694195675462560794-deletionmarker-filename.jpg" (this file is saved on disk but empty)
    class VersionId
      attr_reader :id
      def initialize(id)
        @id = id
      end

      def protocol
        PROTOCOL
      end

      def current_reference_id
        self.class.new(Valkyrie::ID.new(string_id.gsub(version, "current")))
      end

      # @return [VersionID] the version_id for the current file
      def resolve_current
        return self unless reference?
        version_files.first
      end

      def file_path
        @file_path ||= string_id.gsub(/^#{Regexp.escape(protocol)}/, '')
      end

      def version_files
        root = Pathname.new(file_path)
        root.parent.children.select { |file| file.basename.to_s.end_with?(filename) }.sort.reverse.map do |file|
          VersionId.new(Valkyrie::ID.new("#{protocol}#{file}"))
        end
      end

      def deletion_marker?
        string_id.include?("deletionmarker")
      end

      def current?
        version_files.first.id == id
      end

      # @return [Boolean] Whether this id is referential (e.g. "current") or absolute (e.g. a timestamp)
      def reference?
        version == "current"
      end

      def versioned?
        string_id.include?("v-")
      end

      def version
        string_id.split("v-").last.split("-", 2).first
      end

      def filename
        string_id.split("v-").last.split("-", 2).last.gsub("deletionmarker-", "")
      end

      def string_id
        id.to_s
      end
    end
  end
end
