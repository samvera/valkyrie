# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::WriteCached::QueryService do
  describe 'with everything in the cache' do
    let(:primary) { NullPersistence::MetadataAdapter.new }
    let(:cache)   { Valkyrie::Persistence::Redis::MetadataAdapter.new }
    let(:adapter) { Valkyrie::Persistence::WriteCached::MetadataAdapter.new(primary_adapter: primary, cache_adapter: cache) }
    it_behaves_like "a Valkyrie query provider"
  end

  describe 'with nothing in the cache' do
    let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
    let(:primary) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }
    let(:cache)   { NullPersistence::MetadataAdapter.new }
    let(:adapter) { Valkyrie::Persistence::WriteCached::MetadataAdapter.new(primary_adapter: primary, cache_adapter: cache) }
    it_behaves_like "a Valkyrie query provider"
  end

  describe 'with a 10-second delayed write primary store and a 15-second expiring cache' do
    let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
    let(:primary) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client, commit_params: { commitWithin: 10 }) }
    let(:cache)   { Valkyrie::Persistence::Redis::MetadataAdapter.new(expiration: 5) }
    let(:adapter) { Valkyrie::Persistence::WriteCached::MetadataAdapter.new(primary_adapter: primary, cache_adapter: cache) }
    it_behaves_like "a Valkyrie query provider"
  end
end
