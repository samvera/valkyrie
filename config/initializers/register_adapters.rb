# frozen_string_literal: true
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
