# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::MetadataAdapter do
  let(:adapter) { described_class.new }
  let(:orm_class) { adapter.resource_factory.orm_class }
  it_behaves_like "a Valkyrie::MetadataAdapter"

  describe "#id" do
    let(:db_config) { adapter.send(:connection_configuration) }

    it "creates an md5 hash from the host and database name" do
      to_hash = "#{db_config[:host]}:#{db_config[:database]}"
      expected = Digest::MD5.hexdigest to_hash
      expect(adapter.id.to_s).to eq expected
    end

    it "works in Rails < 7, when config is in connection_config" do
      allow(orm_class).to receive(:respond_to?).and_call_original
      allow(orm_class).to receive(:respond_to?).with(:connection_db_config).and_return(false)
      allow(Valkyrie::Persistence::Postgres::ORM::Resource).to receive(:connection_config).and_return({ host: "127.0.0.1", database: "test" })

      expect(adapter.id.to_s).to eq Digest::MD5.hexdigest("127.0.0.1:test")
    end

    it "works in Rails > 7, when config is in connection_db_config" do
      allow(orm_class).to receive(:respond_to?).and_call_original
      allow(orm_class).to receive(:respond_to?).with(:connection__config).and_return(false)
      allow(Valkyrie::Persistence::Postgres::ORM::Resource).to receive(:connection_db_config)
        .and_return(double("ActiveRecord::DatabaseConfigurations::HashConfig", configuration_hash: { host: "127.0.0.1", database: "test" }))

      expect(adapter.id.to_s).to eq Digest::MD5.hexdigest("127.0.0.1:test")
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
