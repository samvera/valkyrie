# frozen_string_literal: true
require 'valkyrie/active_model'
Valkyrie::Adapter.register(
  Valkyrie::Persistence::Postgres,
  :postgres
)

Valkyrie::Adapter.register(
  Valkyrie::Persistence::Fedora,
  :fedora
)

Valkyrie::Adapter.register(
  Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection),
  :index_solr
)

Valkyrie::Adapter.register(
  CompositePersister.new(
    Valkyrie.config.adapter.persister,
    Valkyrie::Adapter.find(:index_solr).persister
  ),
  :indexing_persister
)
