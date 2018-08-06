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

  context "converting a DateTime" do
    before do
      raise 'persister must be set with `let(:persister)`' unless defined? persister
      class CustomResource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
        attribute :title
        attribute :author
        attribute :member_ids
        attribute :nested_resource
      end
    end
    after do
      Object.send(:remove_const, :CustomResource)
    end
    let(:resource_class) { CustomResource }

    it "Returns a string when DateTime conversion fails" do
      time1 = DateTime.current
      time2 = Time.current.in_time_zone
      allow(DateTime).to receive(:iso8601).and_raise StandardError.new("bogus exception")
      book = persister.save(resource: resource_class.new(title: [time1], author: [time2]))

      reloaded = query_service.find_by(id: book.id)

      expect(reloaded.title.first[0, 19]).to eq("datetime-#{time1.to_s[0, 10]}")
    end
  end

  describe "#save" do
    # supplement specs from shared_specs/locking_persister with a solr-specific test
    # The only error we catch is the 409 conflict
    context "when updating a resource with an invalid token" do
      before do
        class MyLockingResource < Valkyrie::Resource
          enable_optimistic_locking
          attribute :title
        end
      end

      after do
        ActiveSupport::Dependencies.remove_constant("MyLockingResource")
      end

      it "raises an Rsolr 500 Error" do
        resource = MyLockingResource.new(title: ["My Locked Resource"])
        initial_resource = persister.save(resource: resource)
        invalid_token = Valkyrie::Persistence::OptimisticLockToken.new(adapter_id: adapter.id, token: "NOT_EVEN_A_VALID_TOKEN")
        initial_resource.send("#{Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK}=", [invalid_token])
        expect { persister.save(resource: initial_resource) }.to raise_error(RSolr::Error::Http)
      end
    end
  end
end
