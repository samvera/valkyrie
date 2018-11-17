# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Fedora do
  before(:all) do
    # Start from a clean fedora
    wipe_fedora!(base_path: "test")
  end

  let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test')) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

  it_behaves_like "a Valkyrie::StorageAdapter"
end
