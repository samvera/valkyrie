# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::ChangeSet do
  before do
    class Resource < Valkyrie::Resource
      attribute :author, Valkyrie::Types::Set
    end
    class ResourceChangeSet < Valkyrie::ChangeSet
      self.fields = [:author]
      property :title, virtual: true, required: true
      property :files, virtual: true, multiple: false
      validates :title, presence: true
    end
  end
  after do
    Object.send(:remove_const, :Resource)
    Object.send(:remove_const, :ResourceChangeSet)
  end
  subject(:change_set) { ResourceChangeSet.new(Resource.new) }

  describe ".validators_on" do
    it "the class responds to validators_on" do
      expect(described_class).to respond_to(:validators_on)
    end
  end

  it "can set an append_id" do
    change_set.append_id = Valkyrie::ID.new("test")
    expect(change_set.append_id).to eq Valkyrie::ID.new("test")
    expect(change_set[:append_id]).to eq Valkyrie::ID.new("test")
  end

  describe "#multiple?" do
    it "is not multiple for tagged items" do
      expect(change_set.multiple?(:files)).to eq false
    end
    it "is multiple for un-tagged items" do
      expect(change_set.multiple?(:title)).to eq true
    end
  end

  describe "#required?" do
    it "is true when marked" do
      expect(change_set.required?(:title)).to eq true
    end

    it "is false when not marked" do
      expect(change_set.required?(:files)).to eq false
    end
  end

  describe "#fields=" do
    it "creates a field with a default" do
      change_set.prepopulate!
      expect(change_set.author).to eq []
    end
  end

  describe "#validate" do
    it "revalidates on correction" do
      change_set.validate(title: []) # sets error when title is required
      expect(change_set).not_to be_valid
      change_set.validate(title: ['good title']) # should clear the error
      expect(change_set).to be_valid
    end
  end
end
