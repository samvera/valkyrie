# frozen_string_literal: true
class ImageDerivativeService
  class Factory
    attr_reader :form_persister, :image_config, :use
    delegate :adapter, :storage_adapter, to: :form_persister
    def initialize(form_persister:, image_config: ImageConfig.new(width: 200, height: 150, format: 'jpg', mime_type: 'image/jpeg', output_name: 'thumbnail'), use: [])
      @form_persister = form_persister
      @image_config = image_config
      self.use = use
    end

    def use=(use)
      @use = Array(use) + [Valkyrie::Vocab::PCDMUse.ServiceFile]
    end

    def new(form)
      ::ImageDerivativeService.new(form: form, original_file: original_file(form), form_persister: form_persister, image_config: image_config, use: use)
    end

    def original_file(model)
      members(model).find { |x| x.use.include?(Valkyrie::Vocab::PCDMUse.OriginalFile) }
    end

    def members(model)
      adapter.query_service.find_members(model: model)
    end

    class ImageConfig < Dry::Struct
      attribute :width, Valkyrie::Types::Int
      attribute :height, Valkyrie::Types::Int
      attribute :format, Valkyrie::Types::String
      attribute :mime_type, Valkyrie::Types::String
      attribute :output_name, Valkyrie::Types::String
    end
  end
  attr_reader :form, :original_file, :image_config, :use, :form_persister
  delegate :adapter, :storage_adapter, to: :form_persister
  delegate :width, :height, :format, :output_name, to: :image_config
  delegate :mime_type, to: :original_file
  delegate :persister, to: :adapter
  def initialize(form:, original_file:, form_persister:, image_config:, use:)
    @form = DynamicFormClass.new.new(form.try(:model) || form)
    @original_file = original_file
    @form_persister = form_persister
    @image_config = image_config
    @use = use
  end

  def image_mime_type
    image_config.mime_type
  end

  def create_derivatives
    Hydra::Derivatives::ImageDerivatives.create(filename,
                                                outputs: [{ label: :thumbnail, format: format, size: "#{width}x#{height}>", url: URI("file://#{temporary_output.path}") }])
    form.files = [build_file]
    form_persister.save(form: form)
  end

  class IoDecorator < SimpleDelegator
    attr_reader :original_filename, :content_type, :use
    def initialize(io, original_filename, content_type, use)
      @original_filename = original_filename
      @content_type = content_type
      @use = use
      super(io)
    end
  end

  def build_file
    IoDecorator.new(temporary_output, "#{output_name}.#{format}", mime_type, use)
  end

  def cleanup_derivatives; end

  def filename
    return Pathname.new(file_object.io.path) if file_object.io.respond_to?(:path) && File.exist?(file_object.io.path)
  end

  def file_object
    @file_object ||= Valkyrie::StorageAdapter.find_by(id: original_file.file_identifiers[0])
  end

  def temporary_output
    @temporary_file ||= Tempfile.new
  end

  def valid?
    mime_type.include?("image/tiff")
  end
end
