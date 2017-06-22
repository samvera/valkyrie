# frozen_string_literal: true
class ImageDerivativeService
  class Factory
    attr_reader :adapter, :repository, :width, :height
    def initialize(adapter:, repository:, width: 200, height: 150)
      @adapter = adapter
      @repository = repository
      @width = width
      @height = height
    end

    def new(file_set)
      ::ImageDerivativeService.new(file_set: file_set, original_file: original_file(file_set), adapter: adapter, repository: repository, image_config: image_config)
    end

    def original_file(file_set)
      members(file_set).find { |x| x.use.include?("original") }
    end

    def members(file_set)
      adapter.query_service.find_members(model: file_set)
    end

    def image_config
      ImageConfig.new(width: width, height: height)
    end

    class ImageConfig < Dry::Struct
      attribute :width, Valkyrie::Types::Int
      attribute :height, Valkyrie::Types::Int
    end
  end
  attr_reader :file_set, :original_file, :adapter, :repository, :image_config
  delegate :width, :height, to: :image_config
  delegate :mime_type, to: :original_file
  delegate :persister, to: :adapter
  def initialize(file_set:, original_file:, adapter:, repository:, image_config:)
    @file_set = file_set
    @original_file = original_file
    @adapter = adapter
    @repository = repository
    @image_config = image_config
  end

  def create_derivatives
    Hydra::Derivatives::ImageDerivatives.create(filename,
                                                outputs: [{ label: :thumbnail, format: 'jpg', size: "#{width}x#{height}>", url: URI("file://#{temporary_output.path}") }])
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
