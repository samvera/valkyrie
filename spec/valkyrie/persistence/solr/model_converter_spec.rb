# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Solr::ModelConverter do
  subject(:mapper) { described_class.new(resource, resource_factory: resource_factory) }
  let(:resource_factory) { adapter.resource_factory }
  let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  let(:created_at) { Time.now.utc }
  before do
    class Resource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title, Valkyrie::Types::Set
      attribute :author, Valkyrie::Types::Set
      attribute :birthday, Valkyrie::Types::DateTime.optional
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  let(:resource) do
    instance_double(Resource,
                    id: "1",
                    internal_resource: 'Resource',
                    attributes:
                    {
                      created_at: created_at,
                      internal_resource: 'Resource',
                      title: ["Test", RDF::Literal.new("French", language: :fr)],
                      author: ["Author"]
                    })
  end

  describe "#to_h" do
    it "maps all available properties to the solr record" do
      expect(mapper.convert!).to eq(
        id: resource.id.to_s,
        join_id_ssi: "id-#{resource.id}",
        title_ssim: ["Test", "French"],
        title_tesim: ["Test", "French"],
        title_tsim: ["Test", "French"],
        title_lang_ssim: ["eng", "fr"],
        title_lang_tesim: ["eng", "fr"],
        title_lang_tsim: ["eng", "fr"],
        author_ssim: ["Author"],
        author_tesim: ["Author"],
        author_tsim: ["Author"],
        created_at_dtsi: created_at.iso8601,
        internal_resource_ssim: ["Resource"],
        internal_resource_tesim: ["Resource"],
        internal_resource_tsim: ["Resource"]
      )
    end
  end

  context "when there's an error" do
    let(:resource) do
      instance_double(Resource,
                      id: "1",
                      internal_resource: 'Resource',
                      attributes:
                      {
                        internal_resource: 'Resource',
                        birthdate: Date.parse('1930-10-20')
                      })
    end

    it "raises an error" do
      expect { mapper.convert! }.to raise_error(
        "Unable to cast Resource#birthdate which has been set to an instance of 'Date'"
      )
    end
  end

  describe "#created_at" do
    context "when created_at attribute is a Time" do
      it "returns a String" do
        expect(mapper.created_at).to be_a String
      end
    end

    context "when created_at attribute is nil" do
      let(:created_at) { nil }
      it "returns a String" do
        expect(mapper.created_at).to be_a String
      end
    end
  end
end
