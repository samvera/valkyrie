# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Disk do
  it_behaves_like "a Valkyrie::StorageAdapter"
  let(:storage_adapter) { described_class.new(base_path: Valkyrie::Engine.root.join("tmp", "files_test")) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

  describe ".handles?" do
    it "matches on base_path" do
      expect(storage_adapter.handles?(id: "disk://#{Valkyrie::Engine.root.join('tmp', 'files_test')}")).to eq true
    end

    it "does not match when base_path differs" do
      expect(storage_adapter.handles?(id: "disk://#{Valkyrie::Engine.root.join('tmp', 'wrong')}")).to eq false
    end

    it "does not match when base_path is only a prefix" do
      expect(storage_adapter.handles?(id: "disk://#{Valkyrie::Engine.root.join('tmp', 'files_test_other')}")).to eq false
    end

    it "does not match when the path traverses out of base_path" do
      expect(storage_adapter.handles?(id: "disk://#{Valkyrie::Engine.root.join('tmp', 'files_test')}/../wrong")).to eq false
    end
  end

  context "when given a path outside of base_path" do
    let(:outside_path) { Valkyrie::Engine.root.join("tmp", "outside_files_test", "outside.txt") }
    before do
      class Resource < Valkyrie::Resource
      end
      FileUtils.mkdir_p(outside_path.parent)
      File.write(outside_path, "outside")
    end
    after do
      Object.send(:remove_const, :Resource)
      FileUtils.rm_rf(outside_path.parent)
    end

    it "does not find it" do
      expect { storage_adapter.find_by(id: Valkyrie::ID.new("disk://#{outside_path}")) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "does not find it via traversal" do
      id = Valkyrie::ID.new("disk://#{Valkyrie::Engine.root.join('tmp', 'files_test')}/../outside_files_test/outside.txt")

      expect { storage_adapter.find_by(id: id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "does not delete it" do
      expect { storage_adapter.delete(id: Valkyrie::ID.new("disk://#{outside_path}")) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
      expect(File.exist?(outside_path)).to eq true
    end

    it "does not upload to it" do
      resource = Resource.new(id: "test")

      expect { storage_adapter.upload(file: file, original_filename: "../../../../outside_files_test/uploaded.tif", resource: resource) }.to raise_error ArgumentError
      expect(File.exist?(outside_path.parent.join("uploaded.tif"))).to eq false
    end
  end
end
