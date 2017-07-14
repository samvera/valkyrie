# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PageChangeSet do
  subject(:change_set) { described_class.new(book).prepopulate! }
  let(:book) { Page.new(title: "Test") }

  describe "#title" do
    it "delegates down appropriately" do
      expect(change_set.title).to eq ["Test"]
    end
    it "requires a title be set" do
      change_set.title = []
      expect(change_set).not_to be_valid
    end
  end

  describe "#viewing_hint" do
    let(:book) { Page.new(viewing_hint: ["left-to-right"]) }
    it "returns the first one" do
      expect(change_set.viewing_hint).to eq "left-to-right"
    end
  end
end
