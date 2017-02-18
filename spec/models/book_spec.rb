# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Book do
  subject { described_class.new }

  describe "#title" do
    it "is an accessor" do
      subject.title = "Test"
      expect(subject.title).to eq ["Test"]
    end
    it "can store RDF literals" do
      literal = ::RDF::Literal.new("Test", language: :fr)
      subject.title = literal
      expect(subject.title).to eq [literal]
    end
    it "strips blank values" do
      subject.title = ["Test", ""]
      expect(subject.title).to eq ["Test"]
    end
    it "de-duplicates" do
      subject.title = ["Test", "Test"]
      expect(subject.title).to eq ["Test"]
    end
  end

  describe "#member_ids" do
    it "stores local IDs" do
      subject.member_ids = ["123", "456", "789"]
    end
    it "can be set to the IDs created for other books" do
      member = Persister.save(described_class.new)
      parent = described_class.new
      parent.member_ids = member.id
      parent = QueryService.find_by_id(Persister.save(parent).id)

      expect(parent.member_ids).to eq [member.id]
    end
  end

  describe "#id" do
    it "can be set to a string" do
      subject.id = "test"
      expect(subject.id).to eq "test"
    end
  end
end
