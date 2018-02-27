# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::ChangeSet do
  let(:change_set) { ResourceChangeSet.new(Resource.new) }
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
  it_behaves_like "a Valkyrie::ChangeSet"

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
