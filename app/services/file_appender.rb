# frozen_string_literal: true
class FileAppender
  attr_reader :storage_adapter, :persister, :files
  def initialize(storage_adapter:, persister:, files:)
    @storage_adapter = storage_adapter
    @persister = persister
    @files = files
  end

  def append_to(model)
    return model if files.blank?
    file_sets = file_nodes.map do |node|
      file_set = create_file_set(node)
      Valkyrie::DerivativeService.for(file_set).create_derivatives
    end
    model.member_ids = model.member_ids + file_sets.map(&:id)
    model
  end

  def file_nodes
    @file_nodes ||=
      begin
        files.map do |file|
          create_node(file)
        end
      end
  end

  def create_node(file)
    node = persister.save(model: FileNode.new(label: file.original_filename, original_filename: file.original_filename, mime_type: file.content_type, use: Valkyrie::Vocab::PCDMUse.OriginalFile))
    file = storage_adapter.upload(file: file, model: node)
    node.file_identifiers = node.file_identifiers + [file.id]
    persister.save(model: node)
  end

  def create_file_set(file_node)
    persister.save(model: FileSet.new(title: file_node.original_filename, member_ids: file_node.id))
  end
end
