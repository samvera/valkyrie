# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Memory::Persister do
  let(:persister) { Valkyrie::Persistence::Memory::Adapter.new.persister }
  it_behaves_like "a Valkyrie::Persister"
end
