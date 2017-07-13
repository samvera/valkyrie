# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::CompositePersister do
  let(:adapter) { Valkyrie::Persistence::Memory::MetadataAdapter.new }
  let(:query_service) { adapter.query_service }
  let(:persister) do
    described_class.new(
      adapter.persister,
      Valkyrie::Persistence::Memory::MetadataAdapter.new.persister
    )
  end
  it_behaves_like "a Valkyrie::Persister"
end
