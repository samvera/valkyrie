# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::QueryService do
  before do
    client = RSolr.connect(url: SOLR_TEST_URL)
    client.delete_by_query("*:*")
    client.commit
  end

  let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Valkyrie query provider"

  describe "optimistic locking" do
    let(:query_service) { adapter.query_service } unless defined? query_service
    let(:persister) { adapter.persister }

    before do
      class CustomLockingResource < Valkyrie::Resource
        enable_optimistic_locking
        attribute :title
      end
    end

    after do
      Object.send(:remove_const, :CustomLockingResource)
    end

    it "populates the lock token into the optimistic_lock_token attribute" do
      resource = persister.save(resource: CustomLockingResource.new(title: "My Title"))
      resource = query_service.find_by(id: resource.id)
      query_doc = (query_service.connection.get 'select', params: { q: "id:#{resource.id}" })["response"]["docs"].first
      token = Valkyrie::Persistence::OptimisticLockToken.new(adapter_id: adapter.id, token: query_doc["_version_"])
      expect(resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK].first.serialize).to eq token.serialize
    end
  end

  describe "#find_members" do
    before do
      class CustomResource < Valkyrie::Resource
        attribute :member_ids, Valkyrie::Types::Array
      end
    end

    after do
      Object.send(:remove_const, :CustomResource)
    end

    let(:members) { adapter.query_service.find_members(resource: parent) }
    let!(:child1) { adapter.persister.save(resource: CustomResource.new) }
    let!(:child2) { adapter.persister.save(resource: CustomResource.new) }
    let(:parent) { adapter.persister.save(resource: CustomResource.new(member_ids: [child2.id, child1.id])) }

    it "returns all a resource's members in order" do
      expect(members.map(&:id).to_a).to eq [child2.id, child1.id]
    end
  end

  describe "#find_by" do
    before do
      class CustomResource < Valkyrie::Resource; end
    end

    after do
      Object.send(:remove_const, :CustomResource)
    end

    let!(:resource) { adapter.persister.save(resource: CustomResource.new) }

    it "makes one Solr request" do
      allow(adapter.query_service.connection).to receive(:get).and_call_original
      adapter.query_service.find_by(id: resource.id)
      expect(adapter.query_service.connection).to have_received(:get).once
    end
  end

  describe "#find_by_alternate_identifier" do
    before do
      class CustomResource < Valkyrie::Resource
        attribute :alternate_ids, Valkyrie::Types::Set.of(Valkyrie::Types::ID)
      end
    end

    after do
      Object.send(:remove_const, :CustomResource)
    end

    let(:alt_id) { Valkyrie::ID.new('p9s0xfj') }
    let!(:resource) { adapter.persister.save(resource: CustomResource.new(alternate_ids: [alt_id])) }

    it "makes one Solr request" do
      allow(adapter.query_service.connection).to receive(:get).and_call_original
      adapter.query_service.find_by_alternate_identifier(alternate_identifier: resource.alternate_ids.first)
      expect(adapter.query_service.connection).to have_received(:get).once
    end
  end
end
