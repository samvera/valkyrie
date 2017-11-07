# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BookChangeSet do
  subject(:change_set) { described_class.new(book) }
  let(:book) { Book.new(title: "Test") }

  describe "#title" do
    it "delegates down appropriately" do
      expect(change_set.title).to eq ["Test"]
    end
    it "requires a title be set" do
      change_set.title = []
      expect(change_set).not_to be_valid
      change_set.title = ["Test"]
      expect(change_set).to be_valid
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

  describe "#append_id" do
    it "coerces it to a Valkyrie::ID" do
      change_set.validate(append_id: "Test")
      expect(change_set.append_id).to be_kind_of Valkyrie::ID
    end
  end

  describe "#member_ids" do
    it "coerces an array into Valkyrie::IDs" do
      change_set.validate(member_ids: ["1", "2"])
      change_set.member_ids.each do |id|
        expect(id).to be_kind_of Valkyrie::ID
      end
    end
  end

  describe "#a_member_of" do
    it "coerces an array into Valkyrie::IDs" do
      change_set.validate(a_member_of: ["1", "2"])
      change_set.a_member_of.each do |id|
        expect(id).to be_kind_of Valkyrie::ID
      end
    end
  end

  describe "#thumbnail_id" do
    it "coerces it to a Valkyrie::ID" do
      change_set.validate(thumbnail_id: "Test")
      expect(change_set.thumbnail_id).to be_kind_of Valkyrie::ID
    end
  end

  describe "#start_canvas" do
    it "coerces it to a Valkyrie::ID" do
      change_set.validate(start_canvas: "Test")
      expect(change_set.start_canvas).to be_kind_of Valkyrie::ID
    end
  end
end
