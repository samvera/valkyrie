# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
require 'valkyrie/specs/shared_specs/locking_persister'

RSpec.describe Valkyrie::Persistence::Memory::Persister do
  let(:adapter) { Valkyrie::Persistence::Memory::MetadataAdapter.new }
  let(:query_service) { adapter.query_service }
  let(:persister) { adapter.persister }
  it_behaves_like "a Valkyrie::Persister"
  it_behaves_like "a Valkyrie locking persister"
end
