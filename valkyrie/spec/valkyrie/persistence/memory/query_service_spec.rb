# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Memory::QueryService do
  let(:adapter) { Valkyrie::Persistence::Memory::Adapter.new }
  it_behaves_like "a Valkyrie query provider"
end
