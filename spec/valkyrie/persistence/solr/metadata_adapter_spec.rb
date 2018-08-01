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
end
