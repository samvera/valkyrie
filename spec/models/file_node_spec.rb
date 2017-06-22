# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FileNode do
  subject(:file_node) { described_class.new }

  describe "#title" do
    it "is an alias for label" do
      file_node.label = "Test"

      expect(file_node.title).to eq file_node.label
    end
  end

  describe "#download_id" do
    it "is an alias for id" do
      file_node.id = "first"

      expect(file_node.download_id).to eq file_node.id
    end
  end
end
