# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Song do
  subject(:song) { described_class.new }
  let(:resource_klass) { described_class }
  it_behaves_like "a Valkyrie::Resource"

  describe "#title" do
    it "is an accessor" do
      song.title = "Test"
      expect(song.title).to eq ["Test"]
    end
    it "can store RDF literals" do
      literal = ::RDF::Literal.new("Test", language: :fr)
      song.title = literal
      expect(song.title).to eq [literal]
    end
    it "strips blank values" do
      song.title = ["Test", ""]
      expect(song.title).to eq ["Test"]
    end
    it "de-duplicates" do
      song.title = ["Test", "Test"]
      expect(song.title).to eq ["Test"]
    end
  end

  it "creates defaults" do
    b = described_class.new
    expect(b.title).to eq []
  end

  describe "#id" do
    it "can be set to a string" do
      song.id = "test"
      expect(song.id).to eq Valkyrie::ID.new("test")
    end
  end

  describe "factory" do
    let(:song) { FactoryGirl.build(:song) }
    it "builds a public song" do
      expect(song).to be_kind_of(described_class)
      expect(song.read_groups).to eq ['public']
    end
    context "when called with create" do
      let(:song) { FactoryGirl.create_for_repository(:song) }
      it "saves it with the configured persister" do
        expect(song.id).not_to be_nil
      end
    end
  end
end
