# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::MetadataAdapter do
  let(:adapter) { described_class.new }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#id" do
    let(:db_config) { adapter.send(:connection_configuration) }

    it "creates an md5 hash from the host and database name" do
      to_hash = "#{db_config[:host]}:#{db_config[:database]}"
      expected = Digest::MD5.hexdigest to_hash
      expect(adapter.id.to_s).to eq expected
    end
  end

  describe "#connection_configuration" do
    let(:config) { adapter.send(:connection_configuration) }

    it 'returns hash with :host key' do
      expect(config[:host]).not_to be_nil
    end

    it 'returns hash with :database key' do
      expect(config[:database]).not_to be_nil
    end
  end
end
