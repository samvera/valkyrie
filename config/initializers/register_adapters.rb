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

  Valkyrie::FileRepository.register(
    Valkyrie::FileRepository::DiskRepository.new(base_path: Rails.root.join("tmp", "repo")),
    :disk
  )

  Valkyrie::FileRepository.register(
    Valkyrie::FileRepository::Memory.new,
    :memory
  )

  persister_list = Valkyrie::Decorators::DecoratorList.new(
    Valkyrie::Decorators::DecoratorWithArguments.new(FileSetAppendingPersister,
                                                     repository: Valkyrie.config.storage_adapter,
                                                     node_factory: FileNode,
                                                     file_container_factory: FileSet),
    ParentCleanupPersister,
    AppendingPersister
  )

  Valkyrie::Adapter.register(
    Valkyrie::AdapterContainer.new(persister: persister_list.new(
      CompositePersister.new(
        Valkyrie.config.adapter.persister,
        Valkyrie::Adapter.find(:index_solr).persister
      )
    ),
                                   query_service: Valkyrie.config.adapter.query_service),
    :indexing_persister
  )

  Valkyrie::DerivativeService.services << ImageDerivativeService::Factory.new(Valkyrie::Adapter.find(:indexing_persister), Valkyrie.config.storage_adapter)
end
