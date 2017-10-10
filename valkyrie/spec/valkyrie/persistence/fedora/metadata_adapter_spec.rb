# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::MetadataAdapter do
  let(:adapter) { described_class.new(connection: ::Ldp::Client.new("http://localhost:8988/rest"), base_path: "/test_fed") }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#schema" do
    context "by default" do
      specify { expect(adapter.schema).to be_a Valkyrie::Persistence::Fedora::PermissiveSchema }
    end

    context "with a custom schema" do
      let(:adapter) { described_class.new(connection: ::Ldp::Client.new("http://localhost:8988/rest"), base_path: "/test_fed", schema: "custom-schema") }
      specify { expect(adapter.schema).to eq("custom-schema") }
    end
  end
end
