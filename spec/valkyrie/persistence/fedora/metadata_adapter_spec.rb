# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::MetadataAdapter do
  let(:adapter) { described_class.new(connection: ::Ldp::Client.new("http://localhost:8988/rest"), base_path: "test_fed") }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#schema" do
    context "by default" do
      specify { expect(adapter.schema).to be_a Valkyrie::Persistence::Fedora::PermissiveSchema }
    end

    context "with a custom schema" do
      let(:adapter) { described_class.new(connection: ::Ldp::Client.new("http://localhost:8988/rest"), base_path: "test_fed", schema: "custom-schema") }
      specify { expect(adapter.schema).to eq("custom-schema") }
    end
  end

  describe "#id_to_uri" do
    it "converts ids with a slash" do
      id = "test/default"
      expect(adapter.id_to_uri(id).to_s).to eq "http://localhost:8988/rest/test_fed/te/st/test%2Fdefault"
    end
  end

  describe "#uri_to_id" do
    it "converts ids with a slash" do
      uri = adapter.id_to_uri("test/default")
      expect(adapter.uri_to_id(uri).to_s).to eq "test/default"
    end
  end

  describe "#pair_path" do
    it "creates pairs until the first dash" do
      expect(adapter.pair_path('abcdef-ghijkl')).to eq('ab/cd/ef')
    end
    it "creates pairs until the first slash" do
      expect(adapter.pair_path('admin_set/default')).to eq('ad/mi/n_/se/t')
    end
  end

  describe "#id" do
    it "creates an md5 hash from the connection_prefix" do
      expected = Digest::MD5.hexdigest adapter.connection_prefix
      expect(adapter.id.to_s).to eq expected
    end
  end
end
