# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BookForm do
  subject(:form) { described_class.new(book) }
  let(:book) { Book.new(title: "Test") }

  describe "#title" do
    it "delegates down appropriately" do
      expect(form.title).to eq ["Test"]
    end
    it "requires a title be set" do
      form.title = []
      expect(form).not_to be_valid
    end
  end

  describe "#append_id" do
    it "coerces it to a Valkyrie::ID" do
      form.validate(append_id: "Test")
      expect(form.append_id).to be_kind_of Valkyrie::ID
    end
  end

  describe "#member_ids" do
    it "coerces an array into Valkyrie::IDs" do
      form.validate(member_ids: ["1", "2"])
      form.member_ids.each do |id|
        expect(id).to be_kind_of Valkyrie::ID
      end
    end
  end

  describe "#a_member_of" do
    it "coerces an array into Valkyrie::IDs" do
      form.validate(a_member_of: ["1", "2"])
      form.a_member_of.each do |id|
        expect(id).to be_kind_of Valkyrie::ID
      end
    end
  end

  describe "#thumbnail_id" do
    it "coerces it to a Valkyrie::ID" do
      form.validate(thumbnail_id: "Test")
      expect(form.thumbnail_id).to be_kind_of Valkyrie::ID
    end
  end

  describe "#start_canvas" do
    it "coerces it to a Valkyrie::ID" do
      form.validate(start_canvas: "Test")
      expect(form.start_canvas).to be_kind_of Valkyrie::ID
    end
  end
end
