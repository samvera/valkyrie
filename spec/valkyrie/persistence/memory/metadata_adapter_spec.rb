# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Memory::MetadataAdapter do
  let(:adapter) { described_class.new }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#id" do
    it "creates a unique identifier for each instance" do
      expect(adapter.id.to_s).not_to eq described_class.new.id.to_s
    end
  end
end
