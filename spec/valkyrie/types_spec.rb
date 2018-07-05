# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Types do
  before do
    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::SingleValuedString
      attribute :authors, Valkyrie::Types::Array
      attribute :geonames_uri, Valkyrie::Types::URI
      attribute :thumbnail_id, Valkyrie::Types::ID
      attribute :embargo_release_date, Valkyrie::Types::Set.of(Valkyrie::Types::DateTime).optional
      attribute :set_of_values, Valkyrie::Types::Set
      attribute :my_flag, Valkyrie::Types::Bool
      attribute :nested_resource_array, Valkyrie::Types::Array.of(Resource.optional)
      attribute :nested_resource_array_of, Valkyrie::Types::Array.of(Resource.optional)
      attribute :nested_resource_set, Valkyrie::Types::Set.of(Resource.optional)
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

  describe Valkyrie::Types::OptimisticLockToken do
    it "casts from a string" do
      serialized_token = Valkyrie::Persistence::OptimisticLockToken.new(adapter_id: "adapter_id", token: Valkyrie::ID.new("token")).serialize

      expect(described_class[serialized_token]).to be_a Valkyrie::Persistence::OptimisticLockToken
    end
  end

  describe "Single Valued String" do
    it "returns the first of a set of values" do
      resource = Resource.new(title: ["one", "two"])
      expect(resource.title).to eq "one"
    end
  end

  describe "The INT type" do
    it "works, but says it's deprecated" do
      expect { Valkyrie::Types::Int[1] }.to output(/DEPRECATION/).to_stderr
      expect { Valkyrie::Types::Coercible::Int[1] }.to output(/DEPRECATION/).to_stderr
    end
  end

  describe 'The array type' do
    it 'is not modifiable' do
      # We don't want to modify the defaults in the schema.
      expect { Resource.new.authors << 'foo' }.to raise_error(RuntimeError, "can't modify frozen Array")
    end
    it "doesn't create things inside if no value is passed" do
      expect(Resource.new.nested_resource_array).to eq []
      expect(Resource.new(title: "bla").nested_resource_array).to eq []
    end
    it "doesn't create things inside if no value is passed via of" do
      expect(Resource.new.nested_resource_array_of).to eq []
      expect(Resource.new(title: "bla").nested_resource_array_of).to eq []
    end
    it "returns an empty array if given an empty hash" do
      resource = Resource.new(authors: {})
      expect(resource.authors).to eq []
    end
    it "can have .member called on it, but will say it's deprecated" do
      expect { Valkyrie::Types::Coercible::Array.member(Valkyrie::Types::String) }.to output(/DEPRECATION/).to_stderr
    end
  end

  describe "the DateTime type" do
    it "can be set as a time inside an array" do
      resource = Resource.new(embargo_release_date: 2.days.ago)
      expect(resource.embargo_release_date.first).to be_a Time
    end
  end

  describe "a set of values" do
    it "can contain any type except empty string and nil" do
      resource = Resource.new(set_of_values: ["", nil, "one", 2, false, Valkyrie::ID.new("")])
      expect(resource.set_of_values).to contain_exactly "one", 2, false
    end
    it "doesn't create things inside if no value is passed" do
      expect(Resource.new.nested_resource_set).to eq []
      expect(Resource.new(title: "bla").nested_resource_set).to eq []
    end
    it "can create things" do
      resource = Resource.new(nested_resource_set: { title: "test" })
      expect(resource.nested_resource_set.length).to eq 1
    end
    it "returns an empty array if given an empty hash" do
      resource = Resource.new(set_of_values: {})
      expect(resource.set_of_values).to eq []
    end
    it "can use .member" do
      expect { Valkyrie::Types::Set.member(Valkyrie::Types::String) }.not_to raise_error
    end
  end

  describe "A boolean value" do
    it "returns the boolean value set" do
      resource = Resource.new(my_flag: true)
      expect(resource.my_flag).to be true
    end
  end
end
