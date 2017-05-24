# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Book do
  subject(:book) { described_class.new }
  let(:model_klass) { described_class }
  it_behaves_like "a Valkyrie::Model"

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

  it "creates defaults" do
    b = described_class.new
    expect(b.title).to eq []
    expect(b.member_ids).to eq []
  end

  it "casts member_ids" do
    b = described_class.new
    b.member_ids = 1
    expect(b.member_ids).to eq [1]
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
      expect(book.id).to eq Valkyrie::ID.new("test")
    end
  end

  describe "factory" do
    let(:book) { FactoryGirl.build(:book) }
    it "builds a public book" do
      expect(book).to be_kind_of(described_class)
      expect(book.read_groups).to eq ['public']
    end
    context "when called with create" do
      let(:book) { FactoryGirl.create_for_repository(:book) }
      it "saves it with the configured persister" do
        expect(book.id).not_to be_nil
      end
    end
  end
end
