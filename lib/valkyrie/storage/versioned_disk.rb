# frozen_string_literal: true
module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data on disk
  class VersionedDisk
    attr_reader :base_path, :path_generator, :file_mover
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
    def upload(file:, original_filename:, resource: nil, **_extra_arguments)
      version_timestamp = current_timestamp
      new_path = path_generator.generate(resource: resource, file: file, original_filename: "v-#{version_timestamp}-#{original_filename}")
      FileUtils.mkdir_p(new_path.parent)
      file_mover.call(file.try(:path) || file.try(:disk_path), new_path)
      find_by(id: Valkyrie::ID.new("versiondisk://#{new_path}"))
    end

    def current_timestamp
      Time.now.strftime("%s%N")
    end

    def upload_version(id:, file:)
      version_timestamp = current_timestamp
      version_id = version_id(id)
      # It's a deletion marker..
      version_id = version_files(id: id)[1] if version_id.to_s.include?("v--")
      existing_path = file_path(version_id)
      _, version, _post = split_version(version_id)
      new_path = Pathname.new(existing_path.gsub(version, version_timestamp.to_s))
      FileUtils.mkdir_p(new_path.parent)
      file_mover.call(file.try(:path) || file.try(:disk_path), new_path)
      find_by(id: Valkyrie::ID.new("versiondisk://#{new_path}"))
    end

    def find_versions(id:)
      version_files(id: id).select { |x| !x.to_s.include?("deletionmarker") }.map do |file|
        find_by(id: Valkyrie::ID.new("versiondisk://#{file}"))
      end
    end

    def version_files(id:)
      root = Pathname.new(file_path(id))
      _, _version, original_name = split_version(id)
      root.parent.children.select { |file| file.basename.to_s.end_with?(original_name) }.sort.reverse
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?("versiondisk://#{base_path}")
    end

    # @param feature [Symbol] Feature to test for.
    # @return [Boolean] true if the adapter supports the given feature
    def supports?(feature)
      return true if feature == :versions
      false
    end

    def file_path(version_id)
      version_id.to_s.gsub(/^versiondisk:\/\//, '')
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      version_id = version_id(id)
      current_version = current_version_id(id)
      Valkyrie::StorageAdapter::File.new(id: Valkyrie::ID.new(current_version.to_s), io: ::Valkyrie::Storage::Disk::LazyFile.open(file_path(version_id), 'rb'), version_id: version_id)
    rescue Errno::ENOENT
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    def version_id(id)
      return id unless id.to_s.include?("v-")
      pre_version, version, post_version = split_version(id)
      version = get_current_version(id) if version == "current"
      Valkyrie::ID.new("#{pre_version}v-#{version}-#{post_version}")
    end

    def current_version_id(id)
      return id unless id.to_s.include?("v-")
      pre_version, version, post_version = split_version(id)
      return id if version == "current"
      Valkyrie::ID.new("#{pre_version}v-current-#{post_version}")
    end

    def get_current_version(id)
      current_version_id = version_files(id: id)&.first
      return nil if current_version_id.nil?
      return nil if current_version_id.to_s.include?("deletionmarker")
      _, version, _post_version = split_version(current_version_id)
      version
    end

    def split_version(id)
      pre_version, post_version = id.to_s.split("v-")
      version, post_version = post_version.split("-", 2)
      [pre_version, version, post_version]
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:, purge_versions: false)
      path = file_path(version_id(id))
      if purge_versions
        version_files(id: id).each do |file|
          FileUtils.rm_rf(file)
        end
      elsif version_id(id).to_s.include?(get_current_version(id))
        # Leave a deletion marker behind.
        version_timestamp = current_timestamp
        version_id = version_id(id)
        existing_path = file_path(version_id)
        _, version, _post = split_version(version_id)
        new_path = Pathname.new(existing_path.gsub(version, "#{version_timestamp}-deletionmarker"))
        FileUtils.mkdir_p(new_path.parent)
        File.open(new_path, 'w') { |f| f.puts "Deleted" }
      elsif File.exist?(path)
        FileUtils.rm_rf(path)
      end
    end
  end
end
