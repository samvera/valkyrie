require 'rails_helper'

RSpec.describe BookForm do
  subject { described_class.new(book) }
  let(:book) { Book.new(title: "Test") }

  describe "#title" do
    it "delegates down appropriately" do
      expect(subject.title).to eq ["Test"]
    end
  end
end
