# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Disk do
  it_behaves_like "a Valkyrie::StorageAdapter"
  let(:storage_adapter) { described_class.new(base_path: ROOT_PATH.join("tmp", "files_test")) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

  describe ".handles?" do
    it "matches on base_path" do
      expect(storage_adapter.handles?(id: "disk://#{ROOT_PATH.join('tmp', 'files_test')}")).to eq true
    end

    it "does not match when base_path differs" do
      expect(storage_adapter.handles?(id: "disk://#{ROOT_PATH.join('tmp', 'wrong')}")).to eq false
    end
  end
end
