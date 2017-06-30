# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::PersistDerivatives do
  describe ".call" do
    it "takes an input stream and copies it to the output" do
      input = File.open(ROOT_PATH.join("spec", "fixtures", "files", "example.tif"))
      output = Tempfile.new
      described_class.call(input, url: "file://#{output.path}")

      expect(File.read(output.path)).to eq File.read(input.path)
    end
  end
end
