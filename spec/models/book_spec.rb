require 'spec_helper'

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
  end

  describe "#id" do
    it "can be set to a string" do
      subject.id = "test"
      expect(subject.id).to eq "test"
    end
  end
end
