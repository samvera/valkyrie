# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Book do
  subject(:book) { described_class.new }

  describe "#title" do
    it "is an accessor" do
      book.title = "Test"
      expect(book.title).to eq ["Test"]
    end
    it "can store RDF literals" do
      literal = ::RDF::Literal.new("Test", language: :fr)
      book.title = literal
      expect(book.title).to eq [literal]
    end
    it "strips blank values" do
      book.title = ["Test", ""]
      expect(book.title).to eq ["Test"]
    end
    it "de-duplicates" do
      book.title = ["Test", "Test"]
      expect(book.title).to eq ["Test"]
    end
  end

  describe "#member_ids" do
    it "stores local IDs" do
      book.member_ids = ["123", "456", "789"]
    end
    it "can be set to the IDs created for other books" do
      member = Persister.save(model: described_class.new)
      parent = described_class.new
      parent.member_ids = member.id
      parent = QueryService.find_by(id: Persister.save(model: parent).id)

      expect(parent.member_ids).to eq [member.id]
    end
  end

  describe "#id" do
    it "can be set to a string" do
      book.id = "test"
      expect(book.id).to eq "test"
    end
  end
end
