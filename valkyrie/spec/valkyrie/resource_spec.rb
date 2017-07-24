# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Resource do
  before do
    class Resource < Valkyrie::Resource
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title, Valkyrie::Types::Set
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  subject(:resource) { Resource.new }
  describe "#fields" do
    it "returns all configured fields as an array of symbols" do
      expect(Resource.fields).to eq [:internal_resource, :created_at, :updated_at, :id, :title]
    end
  end

  describe "#has_attribute?" do
    it "returns true for fields that exist" do
      expect(resource.has_attribute?(:title)).to eq true
      expect(resource.has_attribute?(:not)).to eq false
    end
  end

  describe "#column_for_attribute" do
    it "returns the column" do
      expect(resource.column_for_attribute(:title)).to eq :title
    end
  end

  describe "#persisted?" do
    it "returns false if the ID is gone" do
      expect(resource).not_to be_persisted
    end
    it "returns true if the ID exists" do
      resource.id = "test"
      expect(resource).to be_persisted
    end
  end

  describe "#to_key" do
    it "returns the record's id in an array" do
      resource.id = "test"
      expect(resource.to_key).to eq [resource.id]
    end
  end

  describe "#to_model" do
    it "returns itself" do
      expect(resource.to_model).to eq resource
    end
  end

  describe "#model_name" do
    it "returns a model name" do
      expect(resource.model_name).to be_kind_of(ActiveModel::Name)
    end
  end

  describe "#to_s" do
    it "returns a good serialization" do
      resource.id = "test"
      expect(resource.to_s).to eq "Resource: test"
    end
  end
end
