# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PageForm do
  subject(:form) { described_class.new(book) }
  let(:book) { Page.new(title: "Test") }

  describe "#title" do
    it "delegates down appropriately" do
      expect(form.title).to eq ["Test"]
    end
    it "requires a title be set" do
      form.title = []
      expect(form).not_to be_valid
    end
  end

  describe "#viewing_hint" do
    let(:book) { Page.new(viewing_hint: ["left-to-right"]) }
    it "returns the first one" do
      expect(form.viewing_hint).to eq "left-to-right"
    end
  end
end
