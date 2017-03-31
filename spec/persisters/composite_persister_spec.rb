# frozen_string_literal: true
require 'rails_helper'
require 'penguin/specs/shared_specs'

RSpec.describe CompositePersister do
  let(:persister) { described_class.new(Persister.new(adapter: Penguin::Persistence::Postgres), Persister.new(adapter: Penguin::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection))) }
  it_behaves_like "a Penguin::Persister"
end
