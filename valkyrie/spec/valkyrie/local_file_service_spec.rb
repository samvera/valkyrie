# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::LocalFileService do
  describe ".call" do
    it "yields the file name given" do
      file_name = ROOT_PATH.join("spec", "fixtures", "files", "example.tif")
      output = nil
      allow(File).to receive(:open).with(file_name).and_return("test")
      described_class.call(file_name, {}) do |out|
        output = out
      end

      expect(output).to eq "test"
    end
  end
end
