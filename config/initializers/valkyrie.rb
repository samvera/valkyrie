# frozen_string_literal: true
require 'valkyrie'
Rails.application.config.to_prepare do
  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Postgres::Adapter.new,
    :postgres
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::ActiveFedora::Adapter.new,
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
    Valkyrie::Storage::Fedora.new(connection: ActiveFedora.fedora.connection),
    :fedora
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Disk.new(base_path: Rails.root.join("tmp", "files")),
    :disk
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Memory.new,
    :memory
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::IndexingAdapter.new(
      adapter: Valkyrie.config.adapter,
      index_adapter: Valkyrie::Adapter.find(:index_solr)
    ),
    :indexing_persister
  )

  Valkyrie::DerivativeService.services << ImageDerivativeService::Factory.new(
    form_persister: FormPersister.new(
      adapter: Valkyrie::Adapter.find(:indexing_persister),
      storage_adapter: Valkyrie.config.storage_adapter
    ),
    use: [Valkyrie::Vocab::PCDMUse.ThumbnailImage]
  )
end
