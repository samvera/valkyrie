# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::MetadataAdapter do
  let(:adapter) do
    Class.new do
      def self.persister
        :the_persister
      end

      def self.query_service
        :the_query_service
      end
    end
  end
  describe ".register" do
    it "registers an adapter to a short name" do
      described_class.register adapter, :test_adapter

      expect(described_class.find(:test_adapter)).to eq adapter
    end
  end

  describe '.find' do
    subject(:find) { described_class.find(:huh?) }
    context 'when no adapter is registered' do
      it 'raises an error' do
        expect { find }.to raise_error "Unable to find unregistered adapter `huh?'"
      end
    end
  end

  describe '.find_persister_for' do
    subject(:find_persister_for) { described_class.find_persister_for(:test_adapter) }
    context 'with a registered adapter' do
      before do
        described_class.register(adapter, :test_adapter)
      end
      it 'returns the adapters persister object' do
        expect(find_persister_for).to eq(adapter.persister)
      end
    end
    # rubocop:enable RSpec/VerifiedDoubles
  end

  describe '.find_query_service_for' do
    subject(:find_query_service_for) { described_class.find_query_service_for(:test_adapter) }
    context 'with a registered adapter' do
      before do
        described_class.register(adapter, :test_adapter)
      end
      it 'returns the adapters query_service object' do
        expect(find_query_service_for).to eq(adapter.query_service)
      end
    end
  end
end
