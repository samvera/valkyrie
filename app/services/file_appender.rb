# frozen_string_literal: true
# Append a collection of files to a model
class FileAppender
  attr_reader :storage_adapter, :persister, :files, :file_node_persister
  def initialize(storage_adapter:, persister:, files:, file_node_persister: FileNodePersister)
    @storage_adapter = storage_adapter
    @persister = persister
    @files = files
    @file_node_persister = file_node_persister
  end

  def append_to(model)
    return model if files.blank?
    file_sets = build_file_sets || file_nodes
    model.member_ids = model.member_ids + file_sets.map(&:id)
    model
  end

  def build_file_sets
    return if processing_derivatives?
    file_nodes.map do |node|
      file_set = create_file_set(node)
      Valkyrie::DerivativeService.for(FileSetChangeSet.new(file_set)).create_derivatives if node.use.include?(Valkyrie::Vocab::PCDMUse.OriginalFile)
      file_set
    end
  end

  def processing_derivatives?
    !file_nodes.first.use.include?(Valkyrie::Vocab::PCDMUse.OriginalFile)
  end

  def file_nodes
    @file_nodes ||=
      begin
        files.map do |file|
          file_node_persister.create_node(file, persister: persister, storage_adapter: storage_adapter)
        end
      end
  end

  def create_file_set(file_node)
    persister.save(model: FileSet.new(title: file_node.original_filename, member_ids: file_node.id))
  end
end
