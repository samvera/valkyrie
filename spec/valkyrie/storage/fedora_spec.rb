# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Fedora, :wipe_fedora do
  describe "ldp gem deprecation" do
    let(:message) { /\[DEPRECATION\] ldp will not be included/ }
    let(:path) { Bundler.definition.gemfiles.first }

    context "when the gemfile does not have an entry for ldp" do
      it "gives a warning when the module loads" do
        allow(File).to receive(:readlines).with(path).and_return(["gem \"rsolr\"\n"])
        expect do
          load "lib/valkyrie/persistence/fedora.rb"
        end.to output(message).to_stderr
      end
    end

    context "when the gemfile does have an entry for pg" do
      it "does not give a deprecation warning" do
        allow(File).to receive(:readlines).with(path).and_return(["gem \"ldp\", \"~> 1.0\"\n"])
        expect do
          load "lib/valkyrie/persistence/fedora.rb"
        end.not_to output(message).to_stderr
      end
    end
  end
  before do
    class Valkyrie::Specs::FedoraCustomResource < Valkyrie::Resource
    end
  end
  after do
    Valkyrie::Specs.send(:remove_const, :FedoraCustomResource)
  end
  context "fedora 4" do
    before(:all) do
      # Start from a clean fedora
      wipe_fedora!(base_path: "test", fedora_version: 4)
    end

    let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test', fedora_version: 4)) }
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

    it_behaves_like "a Valkyrie::StorageAdapter"

    context "when uploading with a content_type" do
      it "passes that on" do
        io_file = file.tempfile

        resource = Valkyrie::Specs::FedoraCustomResource.new(id: SecureRandom.uuid)

        expect(uploaded_file = storage_adapter.upload(
          file: io_file,
          original_filename: 'foo.jpg',
          resource: resource,
          fake_upload_argument: true,
          content_type: "image/tiff"
        )).to be_kind_of Valkyrie::StorageAdapter::File

        uri = storage_adapter.fedora_identifier(id: uploaded_file.id)
        response = Faraday.head(uri.to_s)

        expect(response.headers["content-type"]).to eq "image/tiff"
      end
    end
  end

  context "fedora 5" do
    before(:all) do
      # Start from a clean fedora
      wipe_fedora!(base_path: "test", fedora_version: 5)
    end

    let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test', fedora_version: 5)) }
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

    it_behaves_like "a Valkyrie::StorageAdapter"

    context "when uploading with a content_type" do
      it "passes that on" do
        io_file = file.tempfile

        resource = Valkyrie::Specs::FedoraCustomResource.new(id: SecureRandom.uuid)

        expect(uploaded_file = storage_adapter.upload(
          file: io_file,
          original_filename: 'foo.jpg',
          resource: resource,
          fake_upload_argument: true,
          content_type: "image/tiff"
        )).to be_kind_of Valkyrie::StorageAdapter::File

        uri = storage_adapter.fedora_identifier(id: uploaded_file.id)
        response = Faraday.head(uri.to_s)

        expect(response.headers["content-type"]).to eq "image/tiff"
      end
    end
  end
end
