# Persist file metadata into the storage adapter
class FedoraFileNodePersister
  # Creates a {FileNode}
  def self.create_node(file, persister:, storage_adapter:)
    byebug
    node = FileNode.for(file: file)
    storage_adapter.upload(file: file, model: node)
    node
  end
end
