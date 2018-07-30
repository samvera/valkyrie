# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
require 'valkyrie/specs/shared_specs/locking_query'

RSpec.describe Valkyrie::Persistence::Solr::QueryService do
  before do
    client = RSolr.connect(url: SOLR_TEST_URL)
    client.delete_by_query("*:*")
    client.commit
  end

  let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
  let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
  it_behaves_like "a Valkyrie query provider"
  it_behaves_like "a Valkyrie locking query provider"

  describe "optimistic locking" do
    let(:query_service) { adapter.query_service } unless defined? query_service
    let(:persister) { adapter.persister }

    before do
      class CustomLockingResource < Valkyrie::Resource
        enable_optimistic_locking
        attribute :id, Valkyrie::Types::ID.optional
        attribute :title
      end
    end

    after do
      Object.send(:remove_const, :CustomLockingResource)
    end

    it "retrieves the lock token and casts it to optimistic_lock_token attribute" do
      resource = persister.save(resource: CustomLockingResource.new(title: "My Title"))
      resource = query_service.find_by(id: resource.id)
      query_doc = (query_service.connection.get 'select', params: { q: "id:#{resource.id}" })["response"]["docs"].first
      expect(resource.optimistic_lock_token.first).to eq query_doc["_version_"]
    end
  end
end
