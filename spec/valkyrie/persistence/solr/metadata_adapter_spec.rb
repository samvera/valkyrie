# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::MetadataAdapter do
  let(:adapter) { described_class.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#id" do
    it "creates an md5 hash from the solr connection base_uri" do
      expected = Digest::MD5.hexdigest adapter.connection.base_uri.to_s
      expect(adapter.id.to_s).to eq expected
    end
  end

  describe "write-only mode" do
    let(:adapter) { described_class.new(connection: client, write_only: true) }
    it_behaves_like "a write-only Valkyrie::MetadataAdapter"
    before do
      class WriteOnlyResource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
        attribute :title
      end
    end
    after do
      Object.send(:remove_const, :WriteOnlyResource)
    end
    context "when soft_commit is false" do
      let(:adapter) { described_class.new(connection: client, write_only: true, soft_commit: false) }
      it_behaves_like "a write-only Valkyrie::MetadataAdapter"
      it "doesn't commit to the repository" do
        adapter.persister.wipe!

        adapter.persister.save(resource: WriteOnlyResource.new(title: "Test Title"))
        result = client.get("select", params: { q: "*:*" })

        expect(result["response"]["numFound"]).to eq 0
        client.commit
        result = client.get("select", params: { q: "*:*" })
        expect(result["response"]["numFound"]).to eq 1
        doc = result["response"]["docs"][0]

        expect(doc["title_tsim"]).to eq(["Test Title"])
        expect(doc["title_ssim"]).to eq(["Test Title"])
        expect(doc["title_tesim"]).to eq(["Test Title"])
        expect(doc["title_tsi"]).to eq("Test Title")
        expect(doc["title_ssi"]).to eq("Test Title")
        expect(doc["title_tesi"]).to eq("Test Title")
      end
    end
    it "can persist a resource" do
      adapter.persister.wipe!
      adapter.persister.save(resource: WriteOnlyResource.new(title: "Test Title"))
      result = client.get("select", params: { q: "*:*" })

      expect(result["response"]["numFound"]).to eq 1
      doc = result["response"]["docs"][0]

      expect(doc["title_tsim"]).to eq(["Test Title"])
      expect(doc["title_ssim"]).to eq(["Test Title"])
      expect(doc["title_tesim"]).to eq(["Test Title"])
      expect(doc["title_tsi"]).to eq("Test Title")
      expect(doc["title_ssi"]).to eq("Test Title")
      expect(doc["title_tesi"]).to eq("Test Title")
    end
    it "can save_all" do
      adapter.persister.wipe!
      adapter.persister.save_all(resources: [WriteOnlyResource.new(title: "First"), WriteOnlyResource.new(title: "Second")])

      result = client.get("select", params: { q: "*:*" })

      expect(result["response"]["numFound"]).to eq 2
      docs = result["response"]["docs"]

      expect(docs.flat_map { |doc| doc["title_tsim"] }).to contain_exactly "First", "Second"
    end
  end
end
