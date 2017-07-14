# Persist file metadata into the persister
class FileNodePersister
  # Creates a {FileNode}
  def self.create_node(file, persister:, storage_adapter:)
    node = persister.save(model: FileNode.for(file: file))
    file = storage_adapter.upload(file: file, model: node)
    node.file_identifiers = node.file_identifiers + [file.id]
    node = Valkyrie::FileCharacterizationService.for(file_node: node, persister: persister).characterize(save: false)
    persister.save(model: node)
  end
end
