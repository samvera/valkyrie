# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::QueryService do
  let(:adapter) { Valkyrie::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection) }
  let(:resource_class) { Book }
  it_behaves_like "a Valkyrie query provider"
end
