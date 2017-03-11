# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe CompositePersister do
  let(:persister) { described_class.new(Persister.new(adapter: Valkyrie::Persistence::Postgres), Persister.new(adapter: Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection))) }
  it_behaves_like "a Valkyrie::Persister"
end
