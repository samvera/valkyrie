# frozen_string_literal: true
class FileSetAppendingPersister
  attr_reader :persister, :storage_adapter, :node_factory, :file_container_factory
  delegate :adapter, :delete, to: :persister
  def initialize(persister, storage_adapter:, node_factory:, file_container_factory:)
    @persister = persister
    @storage_adapter = storage_adapter
    @node_factory = node_factory
    @file_container_factory = file_container_factory
  end

  def save(model:)
    files(model).each do |file|
      file_node = create_node(file)
      file_set = create_file_set(file_node)
      file = storage_adapter.upload(file: file, model: file_node)
      file_node.file_identifiers = file_node.file_identifiers + [file.id]
      persister.save(model: file_node)
      Valkyrie::DerivativeService.for(file_set).create_derivatives
      model.member_ids = model.member_ids + [file_set.id]
    end
    model.try(:sync)
    persister.save(model: model)
  end

  def create_node(file)
    persister.save(model: node_factory.new(label: file.original_filename, original_filename: file.original_filename, mime_type: file.content_type, use: Valkyrie::Vocab::PCDMUse.OriginalFile))
  end

  def create_file_set(file_node)
    persister.save(model: file_container_factory.new(title: file_node.original_filename, member_ids: file_node.id))
  end

  def files(model)
    model.try(:files) || []
  end
end
