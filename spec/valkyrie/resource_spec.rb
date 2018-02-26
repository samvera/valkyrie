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
    context 'when nothing is passed to the constructor' do
      it { is_expected.not_to be_persisted }
    end

    context 'when new_record: false is passed to the constructor' do
      subject(:resource) { Resource.new(new_record: false) }

      it { is_expected.to be_persisted }
    end
  end

  describe "#to_key" do
    it "returns the record's id in an array" do
      resource.id = "test"
      expect(resource.to_key).to eq [resource.id]
    end
  end

  describe "#to_param" do
    it "returns the record's id as a string" do
      resource.id = "test"
      expect(resource.to_param).to eq 'test'
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
    it "returns a model name at the class level" do
      expect(resource.class.model_name).to be_kind_of(ActiveModel::Name)
    end
  end

  describe "#to_s" do
    it "returns a good serialization" do
      resource.id = "test"
      expect(resource.to_s).to eq "Resource: test"
    end
  end

  describe '.human_readable_type=' do
    it 'sets the human readable type' do
      described_class.human_readable_type = 'Bogus Type'
      expect(described_class.human_readable_type).to eq('Bogus Type')
    end
  end

  context "extended class" do
    before do
      class MyResource < Resource
      end
    end
    after do
      Object.send(:remove_const, :MyResource)
    end
    subject(:resource) { MyResource.new }
    describe "#fields" do
      it "returns all configured parent fields as an array of symbols" do
        expect(MyResource.fields).to eq [:internal_resource, :created_at, :updated_at, :id, :title]
      end
    end
  end
end
