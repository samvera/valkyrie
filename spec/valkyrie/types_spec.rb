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
      attribute :relation_values, Valkyrie::Types::Relation
      attribute :ordered_relation_values, Valkyrie::Types::OrderedRelation
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
      let(:message) do
        /\[DEPRECATION\] Valkyrie::IDs will always be equal to their string counterparts in 3.0.0. To silence this message, please either compare IDs or set Valkyrie.config.id_string_equality = true./
      end
      let(:thumbnail_id) { '123' }

      it 'casts to a string' do
        expect(resource.thumbnail_id).to eq Valkyrie::ID.new('123')
      end

      it 'does not equal the equivalent string if ID matches string' do
      end

      it "doesn't echo a deprecated message if configured" do
        Valkyrie.config.id_string_equality = false
        expect do
          expect(resource.thumbnail_id).not_to eq '123'
        end.not_to output(message).to_stderr
      end

      it 'equals the equivalent string if Valkyrie is configured' do
        allow(Valkyrie.config).to receive(:id_string_equality).and_return(true)

        expect(resource.thumbnail_id).to eq '123'
      end
    end

    context 'when an ID is passed in' do
      let(:thumbnail_id) { Valkyrie::ID.new('123') }

      it 'uses the passed in value' do
        expect(resource.thumbnail_id).to eq Valkyrie::ID.new('123')
      end
    end
  end

  describe "Valkyrie::Types::Params::ID" do
    context "when a blank string is passed in" do
      it "returns nil" do
        expect(Valkyrie::Types::Params::ID[""]).to eq nil
      end
    end
    context "when passed a string" do
      it "returns a Valkyrie::Types::ID" do
        expect(Valkyrie::Types::Params::ID["test"]).to be_a Valkyrie::ID
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

  describe "Valkyrie::Types::OptimisticLockToken" do
    it "casts from a string" do
      serialized_token = Valkyrie::Persistence::OptimisticLockToken.new(adapter_id: "adapter_id", token: Valkyrie::ID.new("token")).serialize

      expect(Valkyrie::Types::OptimisticLockToken[serialized_token]).to be_a Valkyrie::Persistence::OptimisticLockToken
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
  end

  describe "A boolean value" do
    it "returns the boolean value set" do
      resource = Resource.new(my_flag: true)
      expect(resource.my_flag).to be true
    end
  end

  describe "the Relation type" do
    context "acts as a Set of Valkyrie::Types::ID" do
      it "can contain IDs" do
        resource = Resource.new(relation_values: [Valkyrie::ID.new("1"), nil, Valkyrie::ID.new("A"), Valkyrie::ID.new("")])
        expect(resource.relation_values).to contain_exactly Valkyrie::ID.new("1"), Valkyrie::ID.new("A")
      end

      it "casts values to ID type" do
        resource = Resource.new(relation_values: [1, "ducks"])
        expect(resource.relation_values).to contain_exactly Valkyrie::ID.new("1"), Valkyrie::ID.new("ducks")
      end
    end
  end

  describe "the OrderedRelation type" do
    context "acts as an ordered Array of Valkyrie::Types::ID" do
      it "can contain IDs" do
        resource = Resource.new(ordered_relation_values: [Valkyrie::ID.new("1"), Valkyrie::ID.new("A")])
        expect(resource.ordered_relation_values).to contain_exactly Valkyrie::ID.new("1"), Valkyrie::ID.new("A")
      end

      it "casts values to ID type" do
        resource = Resource.new(ordered_relation_values: [1, "ducks"])
        expect(resource.ordered_relation_values).to contain_exactly Valkyrie::ID.new("1"), Valkyrie::ID.new("ducks")
      end

      it "returns all values in order including duplicates" do
        dup = Valkyrie::ID.new("1")
        uniq = Valkyrie::ID.new("A")
        resource = Resource.new(ordered_relation_values: [dup, uniq, dup])
        expect(resource.ordered_relation_values).to contain_exactly dup, uniq, dup
      end
    end
  end
end
