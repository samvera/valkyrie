# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BookDecorator do
  describe "#title" do
    it "returns the first of the titles" do
      decorator = described_class.new(Book.new(title: ["First", "Second"]))

      expect(decorator.title).to eq "First"
    end
  end
end
