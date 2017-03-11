# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::Persister do
  let(:persister) { Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection).persister }
  it_behaves_like "a Valkyrie::Persister"
end
