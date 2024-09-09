># frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Solr::ModelConverter do
  subject(:mapper) { described_class.new(resource, resource_factory: resource_factory) }
  let(:resource_factory) { adapter.resource_factory }
  let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  let(:created_at) { Time.now.utc }
  before do
    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::Set
      attribute :author, Valkyrie::Types::Set
      attribute :birthday, Valkyrie::Types::DateTime.optional
      attribute :creator, Valkyrie::Types::String
      attribute :birthdate, Valkyrie::Types::DateTime.optional
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  let(:resource) do
    instance_double(Resource,
                    id: "1",
                    internal_resource: 'Resource',
                    title: ["Test", RDF::Literal.new("French", language: :fr)],
                    author: ["Author"],
                    creator: "Creator",
                    attributes:
                    {
                      created_at: created_at,
                      internal_resource: 'Resource',
                      title: ["Test", RDF::Literal.new("French", language: :fr)],
                      author: ["Author"],
                      creator: "Creator"
                    })
  end
  before do
    allow(resource).to receive(:optimistic_locking_enabled?).and_return(false)
  end

  describe "#to_h" do
    before do
      Timecop.freeze
    end
    after do
      Timecop.return
    end
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
        title_type_tsim: ["http://www.w3.org/1999/02/22-rdf-syntax-ns#langString", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"],
        title_type_ssim: ["http://www.w3.org/1999/02/22-rdf-syntax-ns#langString", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"],
        title_type_tesim: ["http://www.w3.org/1999/02/22-rdf-syntax-ns#langString", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"],
        author_ssim: ["Author"],
        author_tesim: ["Author"],
        author_tsim: ["Author"],
        author_ssi: ["Author"],
        author_tesi: ["Author"],
        author_tsi: ["Author"],
        created_at_dtsi: created_at.iso8601,
        updated_at_dtsi: Time.current.utc.iso8601(6),
        internal_resource_ssim: ["Resource"],
        internal_resource_tesim: ["Resource"],
        internal_resource_tsim: ["Resource"],
        creator_ssim: ["Creator"],
        creator_tesim: ["Creator"],
        creator_tsim: ["Creator"],
        creator_ssi: ["Creator"],
        creator_tesi: ["Creator"],
        creator_tsi: ["Creator"]
      )
    end
  end

  context "when there's an error" do
    let(:resource) do
      instance_double(Resource,
                      id: "1",
                      internal_resource: 'Resource',
                      birthdate: Date.parse('1930-10-20'),
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

  describe "with a long string value" do
    let(:creator) { ("Creator " * 1000).strip }
    let(:resource) do
      instance_double(Resource,
                      id: "1",
                      internal_resource: 'Resource',
                      title: ["Test", RDF::Literal.new("French", language: :fr)],
                      author: ["Author"],
                      creator: creator,
                      attributes:
                        {
                          created_at: created_at,
                          internal_resource: 'Resource',
                          title: ["Test", RDF::Literal.new("French", language: :fr)],
                          author: ["Author"],
                          creator: creator
                        })
    end

    before do
      Timecop.freeze
    end
    after do
      Timecop.return
    end

    it "only maps the long value to the _tsim Solr field" do
      expect(mapper.convert!).to eq(
        id: resource.id.to_s,
        join_id_ssi: "id-#{resource.id}",
        title_ssim: ["Test", "French"],
        title_tesim: ["Test", "French"],
        title_tsim: ["Test", "French"],
        title_lang_ssim: ["eng", "fr"],
        title_lang_tesim: ["eng", "fr"],
        title_lang_tsim: ["eng", "fr"],
        title_type_tsim: ["http://www.w3.org/1999/02/22-rdf-syntax-ns#langString", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"],
        title_type_ssim: ["http://www.w3.org/1999/02/22-rdf-syntax-ns#langString", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"],
        title_type_tesim: ["http://www.w3.org/1999/02/22-rdf-syntax-ns#langString", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString"],
        author_ssim: ["Author"],
        author_tesim: ["Author"],
        author_tsim: ["Author"],
        author_ssi: ["Author"],
        author_tesi: ["Author"],
        author_tsi: ["Author"],
        created_at_dtsi: created_at.iso8601,
        updated_at_dtsi: Time.current.utc.iso8601(6),
        internal_resource_ssim: ["Resource"],
        internal_resource_tesim: ["Resource"],
        internal_resource_tsim: ["Resource"],
        creator_tsim: [creator]
      )
    end
  end
end
