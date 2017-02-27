require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe CompositePersister do
  let(:persister) { described_class.new(Persister.new(adapter: Valkyrie::Persistence::Postgres), Persister.new(adapter: Valkyrie::Persistence::Solr)) }
  it_behaves_like "a Valkyrie::Persister"
end
