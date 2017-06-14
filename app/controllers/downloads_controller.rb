# frozen_string_literal: true
class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def show
    send_content
  end

  class FileWithMetadata < Dry::Struct
    delegate :size, :read, :stream, to: :file
    attribute :id, Valkyrie::Types::Any
    attribute :file, Valkyrie::Types::Any
    attribute :mime_type, Valkyrie::Types::SingleValuedString
    attribute :original_name, Valkyrie::Types::SingleValuedString
  end

  def load_file
    binary_file = storage_adapter.find_by(id: file_identifier)
    FileWithMetadata.new(id: file_identifier, file: binary_file, mime_type: asset.mime_type, original_name: asset.original_filename.first)
  end

  # Customize the :download ability in your Ability class, or override this method
  def authorize_download!
    authorize! :download, asset
  end

  # Copied from hydra-head and adjusted to handle the fact that we don't have a
  # modified_date in Valkyrie yet.
  def prepare_file_headers
    send_file_headers! content_options
    response.headers['Content-Type'] = file.mime_type
    response.headers['Content-Length'] ||= file.size.to_s
    # Prevent Rack::ETag from calculating a digest over body
    response.headers['Last-Modified'] = modified_date
    self.content_type = file.mime_type
  end

  def modified_date
    return unless asset.respond_to?(:modified_date)
    # Copied/pasted from Hydra-Head.
    asset.modified_date.utc.strftime("%a, %d %b %Y %T GMT")
  end

  def file_identifier
    asset.file_identifiers.first
  end

  def asset
    @asset ||= query_service.find_by(id: Valkyrie::ID.new(params[:id]))
  end

  def query_service
    Valkyrie.config.adapter.query_service
  end

  def storage_adapter
    Valkyrie::FileRepository
  end
end
