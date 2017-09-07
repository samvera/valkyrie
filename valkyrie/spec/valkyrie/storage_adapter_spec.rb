# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::StorageAdapter do
  let(:storage_adapter) { Valkyrie::Storage::Memory.new }
  before do
    described_class.register(storage_adapter, :example)
  end
  after do
    described_class.unregister(:example)
  end
  describe ".register" do
    it "can register a storage_adapter by a short name for easier access" do
      expect(described_class.find(:example)).to eq storage_adapter
    end
  end

  describe ".find_by" do
    it "delegates down to its storage_adapters to find one which handles the given identifier" do
      file = instance_double(Valkyrie::StorageAdapter::StreamFile, id: "yo")
      allow(storage_adapter).to receive(:handles?).and_return(true)
      allow(storage_adapter).to receive(:find_by).and_return(file)
      described_class.register(storage_adapter, :find_test)

      expect(described_class.find_by(id: file.id)).to eq file
      expect(storage_adapter).to have_received(:find_by).with(id: "yo")
    end
  end
end
