# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::Fedora, :wipe_fedora do
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

    let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 4)) }
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

    let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 5)) }
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
          let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 5)) }

          it 'produces a valid URI' do
            expected_uri = "fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/test/AN1D4UHA/original"
            expect(uploaded_file.id.to_s).to eq expected_uri
          end
        end

        context "when basepath uses default (e.g. '/')" do
          let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: '/', fedora_version: 5)) }

          it 'produces a valid URI' do
            expected_uri = RDF::URI.new("fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/AN1D4UHA/original")
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
        let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 5)) }

        it 'produces a valid URI' do
          expected_uri = "fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/test/AN/1D/4U/HA/AN1D4UHA/original"
          expect(uploaded_file.id.to_s).to eq expected_uri
        end
      end

      context 'when sending pairtree configuration parameters' do
        let(:storage_adapter) do
          described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 5,
                                                      fedora_pairtree_count: 4,
                                                      fedora_pairtree_length: 2))
        end
        let(:uploaded_file) do
          storage_adapter.upload(
            file: io_file,
            original_filename: 'foo.jpg',
            resource: resource,
            fake_upload_argument: true,
            content_type: "image/tiff"
          )
        end

        it 'is unaffected and produces expected URI' do
          expected_uri = "fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/test/AN1D4UHA/original"
          expect(uploaded_file.id.to_s).to eq expected_uri
        end
      end
    end
  end

  context "fedora 6" do
    before(:all) do
      # Start from a clean fedora
      wipe_fedora!(base_path: "test", fedora_version: 6)
    end

    let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 6)) }
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
          let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 6)) }

          it 'produces a valid URI' do
            expected_uri = "fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/test/AN1D4UHA/original"
            expect(uploaded_file.id.to_s).to eq expected_uri
          end
        end

        context "when basepath uses default (e.g. '/')" do
          let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: '/', fedora_version: 6)) }

          it 'produces a valid URI' do
            expected_uri = RDF::URI.new("fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/AN1D4UHA/original")
            expect(uploaded_file.id.to_s).to eq expected_uri
          end
        end
      end

      context 'when using pairtree resource uri transformer' do
        let(:storage_adapter) do
          described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 6.5,
                                                      fedora_pairtree_count: 4,
                                                      fedora_pairtree_length: 2))
        end

        it 'produces a valid URI' do
          expected_uri = "fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/test/AN/1D/4U/HA/AN1D4UHA/original"
          expect(uploaded_file.id.to_s).to eq expected_uri
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
        let(:storage_adapter) { described_class.new(**fedora_adapter_config(base_path: 'test', fedora_version: 6)) }

        it 'produces a valid URI' do
          expected_uri = "fedora://#{storage_adapter.connection.http.url_prefix.to_s.gsub('http://', '')}/test/AN/1D/4U/HA/AN1D4UHA/original"
          expect(uploaded_file.id.to_s).to eq expected_uri
        end
      end
    end
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
