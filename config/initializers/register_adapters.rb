# frozen_string_literal: true
require 'valkyrie/active_model'
Rails.application.config.to_prepare do
  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Postgres,
    :postgres
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Fedora,
    :fedora
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Memory::Adapter.new,
    :XXTREME
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection),
    :index_solr
  )

  Valkyrie::Adapter.register(
    AppendingPersister.new(
      CompositePersister.new(
        Valkyrie.config.adapter.persister,
        Valkyrie::Adapter.find(:index_solr).persister
      )
    ),
    :indexing_persister
  )
end
