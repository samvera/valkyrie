# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::MetadataAdapter do
  describe ".register" do
    let(:adapter) { instance_double(described_class) }
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
end
