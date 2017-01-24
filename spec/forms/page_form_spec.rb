# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PageForm do
  subject { described_class.new(book) }
  let(:book) { Page.new(title: "Test") }

  describe "#title" do
    it "delegates down appropriately" do
      expect(subject.title).to eq ["Test"]
    end
    it "requires a title be set" do
      subject.title = []
      expect(subject).not_to be_valid
    end
  end
end
