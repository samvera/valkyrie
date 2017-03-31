# frozen_string_literal: true
require 'penguin/active_model'
Rails.application.config.to_prepare do
  Penguin::Adapter.register(
    Penguin::Persistence::Postgres,
    :postgres
  )

  Penguin::Adapter.register(
    Penguin::Persistence::Fedora,
    :fedora
  )

  Penguin::Adapter.register(
    Penguin::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection),
    :index_solr
  )

  Penguin::Adapter.register(
    AppendingPersister.new(
      CompositePersister.new(
        Penguin.config.adapter.persister,
        Penguin::Adapter.find(:index_solr).persister
      )
    ),
    :indexing_persister
  )
end
