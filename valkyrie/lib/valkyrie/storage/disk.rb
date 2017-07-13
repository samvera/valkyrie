# frozen_string_literal: true
module Valkyrie::Storage
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
      Valkyrie::StorageAdapter::File.new(id: Valkyrie::ID.new(id.to_s), io: ::File.open(file_path(id)))
    end
  end
end
