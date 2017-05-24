# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::Adapter do
  let(:adapter) { described_class.new(connection: Blacklight.default_index.connection) }
  it_behaves_like "a Valkyrie::Adapter"
end
