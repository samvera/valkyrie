# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe CompositePersister do
  let(:persister) do
    described_class.new(
      Persister.new(
        adapter: Valkyrie::Persistence::Memory::Adapter.new
      ),
      Persister.new(
        adapter: Valkyrie::Persistence::Solr::Adapter.new(
          connection: Blacklight.default_index.connection
        )
      )
    )
  end
  it_behaves_like "a Valkyrie::Persister"
end
