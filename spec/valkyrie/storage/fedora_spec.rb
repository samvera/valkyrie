# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Fedora, :wipe_fedora do
  context "fedora 4" do
    before(:all) do
      # Start from a clean fedora
      wipe_fedora!(base_path: "test", fedora_version: 4)
    end

    let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test', fedora_version: 4)) }
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

    it_behaves_like "a Valkyrie::StorageAdapter"
  end

  context "fedora 5" do
    before(:all) do
      # Start from a clean fedora
      wipe_fedora!(base_path: "test", fedora_version: 5)
    end

    let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test', fedora_version: 5)) }
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

    it_behaves_like "a Valkyrie::StorageAdapter"
  end

  context 'no ldp gem' do
    let(:error) { Gem::LoadError.new.tap { |err| err.name = 'ldp' } }
    let(:error_message) do
      "You are using the Fedora adapter without installing the ldp gem.  "\
        "Add `gem 'ldp'` to your Gemfile."
    end

    before do
      allow(Gem::Dependency).to receive(:new).with('ldp', []).and_raise error
    end

    it 'raises an error' do
      expect { load 'lib/valkyrie/persistence/fedora.rb' }.to raise_error(Gem::LoadError,
                                                                          error_message)
    end
  end
end
