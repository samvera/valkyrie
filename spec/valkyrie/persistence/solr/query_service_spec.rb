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
end
