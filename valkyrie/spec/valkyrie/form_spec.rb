# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Form do
  before do
    class Resource < Valkyrie::Model
      attribute :author, Valkyrie::Types::Set
    end
    class ResourceForm < Valkyrie::Form
      self.fields = [:author]
      property :title, virtual: true, required: true
      property :files, virtual: true, multiple: false
    end
  end
  after do
    Object.send(:remove_const, :Resource)
    Object.send(:remove_const, :ResourceForm)
  end
  subject(:form) { ResourceForm.new(Resource.new) }

  it "can set an append_id" do
    form.append_id = Valkyrie::ID.new("test")
    expect(form.append_id).to eq Valkyrie::ID.new("test")
    expect(form[:append_id]).to eq Valkyrie::ID.new("test")
  end

  describe "#multiple?" do
    it "is not multiple for tagged items" do
      expect(form.multiple?(:files)).to eq false
    end
    it "is multiple for un-tagged items" do
      expect(form.multiple?(:title)).to eq true
    end
  end

  describe "#required?" do
    it "is true when marked" do
      expect(form.required?(:title)).to eq true
    end
    it "is false when not marked" do
      expect(form.required?(:files)).not_to eq true
    end
  end

  describe "#fields=" do
    it "creates a field with a default" do
      form.prepopulate!
      expect(form.author).to eq []
    end
  end
end
