# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Redis::Persister do
  let(:adapter) { Valkyrie::Persistence::Redis::MetadataAdapter.new }
  let(:query_service) { adapter.query_service }
  let(:persister) { adapter.persister }
  it_behaves_like "a Valkyrie::Persister"
end
