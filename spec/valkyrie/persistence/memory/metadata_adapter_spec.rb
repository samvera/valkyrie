# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Memory::MetadataAdapter do
  let(:adapter) { described_class.new }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#id" do
    it "creates an md5 hash from the class name" do
      expected = Digest::MD5.hexdigest described_class.to_s
      expect(adapter.id.to_s).to eq expected
    end
  end
end
