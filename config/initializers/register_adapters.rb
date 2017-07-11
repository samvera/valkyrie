# frozen_string_literal: true
require 'valkyrie'
Rails.application.config.to_prepare do
  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Postgres::Adapter,
    :postgres
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::ActiveFedora::Adapter,
    :fedora
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Memory::Adapter.new,
    :memory
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection,
                                             resource_indexer: Valkyrie::Indexers::AccessControlsIndexer),
    :index_solr
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::StorageAdapter::Disk.new(base_path: Rails.root.join("tmp", "files")),
    :disk
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::StorageAdapter::Memory.new,
    :memory
  )

  persister_list = Valkyrie::Decorators::DecoratorList.new(
    Valkyrie::Decorators::DecoratorWithArguments.new(FileSetAppendingPersister,
                                                     storage_adapter: Valkyrie.config.storage_adapter,
                                                     node_factory: FileNode,
                                                     file_container_factory: FileSet),
    ParentCleanupPersister,
    AppendingPersister
  )

  Valkyrie::Adapter.register(
    Valkyrie::AdapterContainer.new(
      persister: Valkyrie::Persistence::IndexingPersister.new(
        persister: Valkyrie.config.adapter.persister,
        index_persister: Valkyrie::Adapter.find(:index_solr).persister,
        workflow_decorator: persister_list
      ),
      query_service: Valkyrie.config.adapter.query_service
    ),
    :indexing_persister
  )

  Valkyrie::DerivativeService.services << ImageDerivativeService::Factory.new(
    adapter: Valkyrie::Adapter.find(:indexing_persister),
    storage_adapter: Valkyrie.config.storage_adapter,
    use: [Valkyrie::Vocab::PCDMUse.ThumbnailImage]
  )
end
