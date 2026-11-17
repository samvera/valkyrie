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

    it "does not match when base_path is only a prefix" do
      expect(storage_adapter.handles?(id: "versiondisk://#{Valkyrie::Engine.root.join('tmp', 'files_test_other')}")).to eq false
    end

    it "does not match when the path traverses out of base_path" do
      expect(storage_adapter.handles?(id: "versiondisk://#{Valkyrie::Engine.root.join('tmp', 'files_test')}/../wrong")).to eq false
    end
  end

  context "when the original filename contains the version prefix" do
    before do
      class Resource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :Resource)
    end

    ["a-iv-70042.jpg", "aiv-1.jpg", "a-v-1.jpg", "v-1.jpg", "v-current-a.jpg", "kaiser-heinrichs-iv-70043.jpg"].each do |filename|
      it "round-trips #{filename}" do
        resource = Resource.new(id: SecureRandom.uuid)
        uploaded = storage_adapter.upload(file: file, original_filename: filename, resource: resource)

        expect(File.basename(uploaded.id.to_s)).to eq "v-current-#{filename}"
        expect(storage_adapter.find_by(id: uploaded.id).version_id).to eq uploaded.version_id

        new_version = storage_adapter.upload_version(id: uploaded.id, file: file)
        expect(File.basename(new_version.id.to_s)).to eq "v-current-#{filename}"
        expect(storage_adapter.find_versions(id: uploaded.id).map(&:version_id)).to eq [new_version.version_id, uploaded.version_id]

        storage_adapter.delete(id: uploaded.id)
        expect { storage_adapter.find_by(id: uploaded.id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
      end
    end
  end

  context "when one filename is a suffix of another in the same directory" do
    before do
      class Resource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :Resource)
    end

    it "keeps their versions separate" do
      resource = Resource.new(id: SecureRandom.uuid)
      short = storage_adapter.upload(file: file, original_filename: "a.jpg", resource: resource)
      long = storage_adapter.upload(file: file, original_filename: "ba.jpg", resource: resource)

      expect(storage_adapter.find_by(id: short.id).version_id).to eq short.version_id
      expect(storage_adapter.find_versions(id: short.id).map(&:version_id)).to eq [short.version_id]

      storage_adapter.delete(id: short.id)
      expect(storage_adapter.find_by(id: long.id).version_id).to eq long.version_id
    end
  end

  context "when base_path contains the version prefix" do
    let(:storage_adapter) { described_class.new(base_path: Valkyrie::Engine.root.join("tmp", "v-files_test")) }
    before do
      class Resource < Valkyrie::Resource
      end
      FileUtils.rm_rf(storage_adapter.base_path)
    end
    after do
      Object.send(:remove_const, :Resource)
      FileUtils.rm_rf(storage_adapter.base_path)
    end

    it "round-trips a file" do
      uploaded = storage_adapter.upload(file: file, original_filename: "plain.tif", resource: Resource.new(id: SecureRandom.uuid))

      expect(File.basename(uploaded.id.to_s)).to eq "v-current-plain.tif"
      expect(storage_adapter.find_by(id: uploaded.id).version_id).to eq uploaded.version_id
    end
  end

  context "when the original filename is empty" do
    before do
      class Resource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :Resource)
    end

    it "does not upload it" do
      expect { storage_adapter.upload(file: file, original_filename: "", resource: Resource.new(id: SecureRandom.uuid)) }.to raise_error ArgumentError
      expect(Dir.glob(File.join(storage_adapter.base_path, "**", "*")).select { |path| File.file?(path) }).to be_empty
    end
  end

  context "when the stored basename has no version prefix" do
    before do
      class Resource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :Resource)
    end

    it "reads a file stored with an empty filename by its version id" do
      path = Pathname.new(storage_adapter.base_path).join("v-1694195675462-")
      FileUtils.mkdir_p(path.parent)
      File.write(path, "empty filename")

      expect(storage_adapter.find_by(id: Valkyrie::ID.new("versiondisk://#{path}")).read).to eq "empty filename"
      expect { storage_adapter.find_by(id: Valkyrie::ID.new("versiondisk://#{path.parent.join('v-current-')}")) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "reads a file uploaded with a slash in its filename" do
      uploaded = storage_adapter.upload(file: file, original_filename: "sub/a.jpg", resource: Resource.new(id: SecureRandom.uuid))

      expect(storage_adapter.find_by(id: uploaded.id).read).to eq File.binread(file.path)
      expect(storage_adapter.find_by(id: uploaded.version_id).read).to eq File.binread(file.path)
      expect(storage_adapter.find_versions(id: uploaded.id)).to eq []
    end

    context "with a path generator that drops the filename" do
      let(:path_generator) do
        Class.new do
          def initialize(base_path:)
            @base_path = base_path
          end

          def generate(resource:, file:, original_filename:) # rubocop:disable Lint/UnusedMethodArgument
            Pathname.new(@base_path).join(resource.id.to_s, "content")
          end
        end
      end
      let(:storage_adapter) { described_class.new(base_path: Valkyrie::Engine.root.join("tmp", "files_test"), path_generator: path_generator) }

      it "reads the uploaded file" do
        uploaded = storage_adapter.upload(file: file, original_filename: "a.jpg", resource: Resource.new(id: SecureRandom.uuid))

        expect(File.basename(uploaded.id.to_s)).to eq "content"
        expect(storage_adapter.find_by(id: uploaded.id).read).to eq File.binread(file.path)
        expect(storage_adapter.find_by(id: uploaded.version_id).read).to eq File.binread(file.path)
      end
    end
  end

  describe "#file_path" do
    it "strips the protocol" do
      path = Valkyrie::Engine.root.join("tmp", "files_test", "v-1694195675462-a.jpg").to_s

      expect(storage_adapter.file_path(Valkyrie::ID.new("versiondisk://#{path}"))).to eq path
    end

    it "raises for a path outside of base_path" do
      id = Valkyrie::ID.new("versiondisk://#{Valkyrie::Engine.root.join('tmp', 'outside_files_test', 'v-1694195675462-a.jpg')}")

      expect { storage_adapter.file_path(id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end
  end

  context "when given an id without a version prefix" do
    let(:unversioned_path) { Pathname.new(storage_adapter.base_path).join("plain.tif") }
    let(:unversioned_id) { Valkyrie::ID.new("versiondisk://#{unversioned_path}") }
    before do
      FileUtils.mkdir_p(storage_adapter.base_path)
      File.write(unversioned_path, "unversioned")
    end

    it "finds it as a plain file" do
      found = storage_adapter.find_by(id: unversioned_id)

      expect(found.id).to eq unversioned_id
      expect(found.version_id).to eq unversioned_id
      expect(found.read).to eq "unversioned"
    end

    it "finds no versions" do
      expect(storage_adapter.find_versions(id: unversioned_id)).to eq []
    end

    it "does not upload a version of it" do
      expect { storage_adapter.upload_version(id: unversioned_id, file: file) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
      expect(unversioned_path.parent.children).to eq [unversioned_path]
    end
  end

  context "when given a path outside of base_path" do
    let(:outside_path) { Valkyrie::Engine.root.join("tmp", "outside_files_test", "v-1694195675462-outside.txt") }
    let(:outside_current_id) { Valkyrie::ID.new("versiondisk://#{outside_path.parent.join('v-current-outside.txt')}") }
    before do
      class Resource < Valkyrie::Resource
      end
      FileUtils.mkdir_p(storage_adapter.base_path)
      FileUtils.mkdir_p(outside_path.parent)
      File.write(outside_path, "outside")
    end
    after do
      Object.send(:remove_const, :Resource)
      FileUtils.rm_rf(outside_path.parent)
    end

    it "does not find it" do
      expect { storage_adapter.find_by(id: Valkyrie::ID.new("versiondisk://#{outside_path}")) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "does not find it by its current reference" do
      expect { storage_adapter.find_by(id: outside_current_id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "does not find it via traversal" do
      id = Valkyrie::ID.new("versiondisk://#{Valkyrie::Engine.root.join('tmp', 'files_test')}/../outside_files_test/v-1694195675462-outside.txt")

      expect { storage_adapter.find_by(id: id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "does not find its versions" do
      expect { storage_adapter.find_versions(id: outside_current_id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
    end

    it "does not delete it" do
      expect { storage_adapter.delete(id: outside_current_id) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
      expect(File.exist?(outside_path)).to eq true
    end

    it "does not upload a version to it" do
      expect { storage_adapter.upload_version(id: outside_current_id, file: file) }.to raise_error Valkyrie::StorageAdapter::FileNotFound
      expect(outside_path.parent.children.length).to eq 1
    end

    it "does not upload to it" do
      resource = Resource.new(id: "test")

      expect { storage_adapter.upload(file: file, original_filename: "x/../../../../../outside_files_test/uploaded.tif", resource: resource) }.to raise_error ArgumentError
      expect(outside_path.parent.children.length).to eq 1
    end
  end
end
