# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::VersionedDisk do
  it_behaves_like "a Valkyrie::StorageAdapter"
  let(:storage_adapter) { described_class.new(base_path: Valkyrie::Engine.root.join("tmp", "files_test")) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
  before do
    FileUtils.rm_rf(Valkyrie::Engine.root.join("tmp", "files_test"))
  end

  describe ".handles?" do
    it "matches on base_path" do
      expect(storage_adapter.handles?(id: "versiondisk://#{Valkyrie::Engine.root.join('tmp', 'files_test')}")).to eq true
    end

    it "does not match when base_path differs" do
      expect(storage_adapter.handles?(id: "versiondisk://#{Valkyrie::Engine.root.join('tmp', 'wrong')}")).to eq false
    end
  end
end
