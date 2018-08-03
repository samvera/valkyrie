# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
require 'valkyrie/specs/shared_specs/locking_query'

RSpec.describe Valkyrie::Persistence::Memory::QueryService do
  let(:adapter) { Valkyrie::Persistence::Memory::MetadataAdapter.new }
  it_behaves_like "a Valkyrie query provider"
  it_behaves_like "a Valkyrie locking query provider"
end
