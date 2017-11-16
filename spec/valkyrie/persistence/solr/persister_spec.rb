# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::Persister do
  let(:query_service) { adapter.query_service }
  let(:persister) { adapter.persister }
  let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Valkyrie::Persister"

  context "when given additional persisters" do
    let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client, resource_indexer: indexer) }
    let(:indexer) { ResourceIndexer }
    before do
      class ResourceIndexer
        attr_reader :resource
        def initialize(resource:)
          @resource = resource
        end

        def to_solr
          {
            "combined_title_ssim" => resource.title + resource.other_title
          }
        end
      end
      class Resource < Valkyrie::Resource
        attribute :id, Valkyrie::Types::ID.optional
        attribute :title, Valkyrie::Types::Set
        attribute :other_title, Valkyrie::Types::Set
      end
    end
    after do
      Object.send(:remove_const, :ResourceIndexer)
      Object.send(:remove_const, :Resource)
    end
    it "can add custom indexing" do
      b = Resource.new(title: ["Test"], other_title: ["Author"])
      expect(adapter.resource_factory.from_resource(resource: b)["combined_title_ssim"]).to eq ["Test", "Author"]
    end
    context "when told to index a really long string" do
      let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
      it "works" do
        b = Resource.new(title: "a" * 100_000)
        expect { adapter.persister.save(resource: b) }.not_to raise_error
      end
    end
  end
end
