# frozen_string_literal: true
require "spec_helper"

describe Valkyrie do
  it "has a version number" do
    expect(Valkyrie::VERSION).not_to be nil
  end
  it "can set a logger" do
    logger = described_class.logger
    fake_logger = instance_double(Logger)

    described_class.logger = fake_logger
    expect(described_class.logger).to eq fake_logger
    described_class.logger = logger
  end
  it "has a configuration loaded from Valkyrie's root" do
    expect { described_class.config }.not_to raise_error
  end
  it "can have a configured adapter, which it looks up" do
    memory_adapter = Valkyrie::Persistence::Memory::MetadataAdapter.new
    Valkyrie::MetadataAdapter.register(memory_adapter, :test)

    expect(described_class.config.metadata_adapter).to eq memory_adapter

    Valkyrie::MetadataAdapter.adapters = {}
  end

  it "can have a configured storage adapter, which it looks up" do
    storage_adapter = Valkyrie::Storage::Memory.new
    Valkyrie::StorageAdapter.register(storage_adapter, :test)

    expect(described_class.config.storage_adapter).to eq storage_adapter

    Valkyrie::StorageAdapter.storage_adapters = {}
  end
  context "when Rails is defined and configured" do
    before do
      module Rails
      end
    end
    it "uses that path" do
      allow(Rails).to receive(:root).and_return(Valkyrie::Engine.root)
      allow(Rails).to receive(:env).and_return("test")

      described_class.instance_variable_set(:@config, nil)
      described_class.config

      expect(Rails).to have_received(:root).exactly(4).times
      expect(described_class.environment).to eq "test"
    end
  end
  context "when Valkyrie::Engine is loaded" do
    it "uses its root for root_path" do
      allow(Valkyrie::Engine).to receive(:root).and_return("bla")

      expect(Valkyrie.root_path).to eq "bla"
    end
  end
  context "when Valkyrie::Engine is not loaded" do
    it "uses the directory of the Valkyrie gem" do
      allow(Valkyrie).to receive(:const_defined?).and_call_original
      allow(Valkyrie).to receive(:const_defined?).with(:Engine).and_return(false)

      expect(Valkyrie.root_path).to eq Pathname.new(Dir.pwd)
    end
  end
  describe ".config" do
    describe '.resource_class_resolver' do
      subject(:resolver) { described_class.config.resource_class_resolver }
      it { is_expected.to respond_to(:call).with(1).argument }
      context 'when called' do
        it 'will by default constantize the given string' do
          expect(resolver.call('Valkyrie')).to eq(described_class)
        end
      end
      context 'when configured' do
        around do |example|
          original = described_class.config.resource_class_resolver
          example.run
          described_class.config.resource_class_resolver = original
        end
        it 'will use the configured lambda' do
          # Yes. This does not conform to the expected output, but
          # I'm looking to demonstrate how this works
          new_resolver = ->(string) { string.to_sym }
          described_class.config.resource_class_resolver = new_resolver
          expect(described_class.config.resource_class_resolver.call('hello')).to eq(:hello)
        end
      end
    end
  end
end
