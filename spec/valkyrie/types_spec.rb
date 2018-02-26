# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Types do
  before do
    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::SingleValuedString
      attribute :authors, Valkyrie::Types::Array
      attribute :geonames_uri, Valkyrie::Types::URI
      attribute :thumbnail_id, Valkyrie::Types::ID
      attribute :embargo_release_date, Valkyrie::Types::Set.member(Valkyrie::Types::DateTime).optional
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end

  describe 'The ID type' do
    let(:resource) { Resource.new(thumbnail_id: thumbnail_id) }

    context 'when an array of ids is passed in' do
      # This happens from the Solr::ORMConverter
      let(:thumbnail_id) { [Valkyrie::ID.new('123')] }

      it 'uses the first' do
        expect(resource.thumbnail_id).to eq Valkyrie::ID.new('123')
      end
    end

    context 'when a string is passed in' do
      let(:thumbnail_id) { '123' }

      it 'casts to a string' do
        expect(resource.thumbnail_id).to eq Valkyrie::ID.new('123')
      end
    end

    context 'when an ID is passed in' do
      let(:thumbnail_id) { Valkyrie::ID.new('123') }

      it 'uses the passed in value' do
        expect(resource.thumbnail_id).to eq Valkyrie::ID.new('123')
      end
    end
  end

  describe 'The URI Type' do
    it 'returns an RDF::URI' do
      # We don't want to modify the defaults in the schema.
      resource = Resource.new(geonames_uri: 'http://sws.geonames.org/6619874')
      expect(resource.geonames_uri).to be_a(RDF::URI)
    end

    it 'returns an RDF::URI for a nil uri' do
      # We don't want to modify the defaults in the schema.
      resource = Resource.new(geonames_uri: nil)
      expect(resource.geonames_uri).to be_nil
    end
  end

  describe "Single Valued String" do
    it "returns the first of a set of values" do
      resource = Resource.new(title: ["one", "two"])
      expect(resource.title).to eq "one"
    end
  end

  describe 'The array type' do
    it 'is not modifiable' do
      # We don't want to modify the defaults in the schema.
      expect { Resource.new.authors << 'foo' }.to raise_error(RuntimeError, "can't modify frozen Array")
    end
  end

  describe "the DateTime type" do
    it "can be set as a time inside an array" do
      resource = Resource.new(embargo_release_date: 2.days.ago)
      expect(resource.embargo_release_date.first).to be_a Time
    end
  end
end
