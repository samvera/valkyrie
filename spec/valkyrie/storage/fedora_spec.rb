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
        response = storage_adapter.connection.http.head(uri.to_s)

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
        response = storage_adapter.connection.http.head(uri.to_s)

        expect(response.headers["content-type"]).to eq "image/tiff"
      end
    end

    context 'testing resource uri transformer' do
      let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
      let(:io_file) { file.tempfile }
      let(:resource) { Valkyrie::Specs::FedoraCustomResource.new(id: 'AN1D4UHA') }
      let(:uploaded_file) do
        storage_adapter.upload(
          file: io_file,
          original_filename: 'foo.jpg',
          resource: resource,
          fake_upload_argument: true,
          content_type: "image/tiff"
        )
      end
      context 'when using default transformer' do
        context 'and basepath is passed in' do
          let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test', fedora_version: 5)) }

          it 'produces a valid URI' do
            expected_uri = 'fedora://localhost:8998/rest/test/AN1D4UHA/original'
            expect(uploaded_file.id.to_s).to eq expected_uri
          end
        end

        context "when basepath uses default (e.g. '/')" do
          let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: '/', fedora_version: 5)) }

          it 'produces a valid URI' do
            expected_uri = RDF::URI.new('fedora://localhost:8998/rest/AN1D4UHA/original')
            expect(uploaded_file.id.to_s).to eq expected_uri
          end
        end
      end

      context 'when transformer is passed in' do
        let(:uploaded_file) do
          storage_adapter.upload(
            file: io_file,
            original_filename: 'foo.jpg',
            resource: resource,
            fake_upload_argument: true,
            content_type: "image/tiff",
            resource_uri_transformer: uri_transformer
          )
        end
        let(:uri_transformer) do
          lambda do |resource, base_url|
            id = CGI.escape(resource.id.to_s)
            head = id.split('/').first
            head.gsub!(/#.*/, '')
            RDF::URI.new(base_url + (head.scan(/..?/).first(4) + [id]).join('/'))
          end
        end
        let(:storage_adapter) { described_class.new(fedora_adapter_config(base_path: 'test', fedora_version: 5)) }

        it 'produces a valid URI' do
          expected_uri = 'fedora://localhost:8998/rest/test/AN/1D/4U/HA/AN1D4UHA/original'
          expect(uploaded_file.id.to_s).to eq expected_uri
        end
      end
    end
  end
end
