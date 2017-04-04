# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::LDP::Adapter do
  let(:adapter) { described_class.new(url: "http://localhost:4567", base_container: "/test/#{SecureRandom.uuid}") }
  it_behaves_like "a Valkyrie::Adapter"
end
