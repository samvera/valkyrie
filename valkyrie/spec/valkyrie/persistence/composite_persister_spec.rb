# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::CompositePersister do
  let(:persister) do
    described_class.new(
      Valkyrie::Persistence::Memory::Adapter.new.persister,
      Valkyrie::Persistence::Memory::Adapter.new.persister
    )
  end
  it_behaves_like "a Valkyrie::Persister"
end
