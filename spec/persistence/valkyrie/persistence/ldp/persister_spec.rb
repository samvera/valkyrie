# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::LDP::Persister do
  let(:adapter) { Valkyrie::Persistence::LDP::Adapter.new(url: "http://localhost:4567", base_container: "/test/#{SecureRandom.uuid}") }
  let(:persister) { adapter.persister }
  it_behaves_like "a Valkyrie::Persister"
end
