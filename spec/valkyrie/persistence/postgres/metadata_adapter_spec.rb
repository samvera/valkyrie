# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::MetadataAdapter do
  let(:adapter) { described_class.new }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#id" do
    it "creates an md5 hash from the host and database name" do
      to_hash = "#{Valkyrie::Persistence::Postgres::ORM::Resource.connection_hash['host']}:#{Valkyrie::Persistence::Postgres::ORM::Resource.connection_hash['database']}"
      expected = Digest::MD5.hexdigest to_hash
      expect(adapter.id.to_s).to eq expected
    end
  end
end
