# frozen_string_literal: true
class ImageDerivativeService
  class Factory
    attr_reader :adapter, :repository
    def initialize(adapter, repository)
      @adapter = adapter
      @repository = repository
    end

    def new(file_set)
      ::ImageDerivativeService.new(file_set, original_file(file_set), adapter, repository)
    end

    def original_file(file_set)
      members(file_set).find { |x| x.use.include?("original") }
    end

    def members(file_set)
      adapter.query_service.find_members(model: file_set)
    end
  end
  attr_reader :file_set, :original_file, :adapter, :repository
  delegate :mime_type, to: :original_file
  delegate :persister, to: :adapter
  def initialize(file_set, original_file, adapter, repository)
    @file_set = file_set
    @original_file = original_file
    @adapter = adapter
    @repository = repository
  end

  def create_derivatives
    Hydra::Derivatives::ImageDerivatives.create(filename,
                                                outputs: [{ label: :thumbnail, format: 'jpg', size: '200x150>', url: URI("file://#{temporary_output.path}") }])
    file_node = persister.save(model: FileNode.new(use: ["derivative", "thumbnail"], label: "thumbnail", mime_type: "image/jpeg"))
    file = IoDecorator.new(temporary_output, "thumbnail.jpg")
    file = repository.upload(file: file, model: file_node)
    file_node.file_identifiers = file.id
    persister.save(model: file_node)
    file_set.member_ids = file_set.member_ids + [file_node.id]
    persister.save(model: file_set)
    file_set
  end

  class IoDecorator < SimpleDelegator
    attr_reader :original_filename
    def initialize(io, original_filename)
      @original_filename = original_filename
      super(io)
    end
  end

  def cleanup_derivatives; end

  def filename
    return Pathname.new(file_object.io.path) if file_object.io.respond_to?(:path) && File.exist?(file_object.io.path)
  end

  def file_object
    @file_object ||= Valkyrie::FileRepository.find_by(id: original_file.file_identifiers[0])
  end

  def temporary_output
    @temporary_file ||= Tempfile.new
  end

  def valid?
    mime_type.include?("image/tiff")
  end
end
