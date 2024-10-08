# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::MetadataAdapter, :wipe_fedora do
  [4, 5, 6, 6.5].each do |fedora_version|
    context "fedora #{fedora_version}" do
      let(:version) { fedora_version }
      let(:fedora_pairtree_count) { 4 }
      let(:fedora_pairtree_length) { 2 }
      let(:adapter) do
        described_class.new(**fedora_adapter_config(base_path: "test_fed", fedora_version: version,
                                                    fedora_pairtree_count: fedora_pairtree_count,
                                                    fedora_pairtree_length: fedora_pairtree_length))
      end
      it_behaves_like "a Valkyrie::MetadataAdapter"

      describe "#schema" do
        context "by default" do
          specify { expect(adapter.schema).to be_a Valkyrie::Persistence::Fedora::PermissiveSchema }
        end

        context "with a custom schema" do
          let(:adapter) { described_class.new(**fedora_adapter_config(base_path: "test_fed", schema: "custom-schema", fedora_version: version)) }
          specify { expect(adapter.schema).to eq("custom-schema") }
        end
      end

      describe "#id_to_uri" do
        it 'returns nil if all forms of id are empty strings' do
          ['', Valkyrie::ID.new('')].each { |id| expect(adapter.id_to_uri(id)).to be_nil }
        end

        it "converts ids with a slash" do
          id = "test/default"
          if adapter.fedora_version == 4

            id = "test/default"
            expect(adapter.id_to_uri(id).to_s).to eq "http://localhost:8988/rest/test_fed/te/st/test%2Fdefault"
          elsif adapter.fedora_version >= 6.5

            expect(adapter.id_to_uri(id).to_s).to eq "#{adapter.url_prefix}/test_fed/te/st/test%2Fdefault"
          else
            expect(adapter.id_to_uri(id).to_s).to eq "#{adapter.url_prefix}/test_fed/test%2Fdefault"
          end
        end
      end

      describe "#uri_to_id" do
        it "converts ids with a slash" do
          uri = adapter.id_to_uri("test/default")
          expect(adapter.uri_to_id(uri).to_s).to eq "test/default"
        end
      end

      describe "#pair_path" do
        it "creates pairs until the first dash" do
          id = 'abcdef-ghijkl'
          if adapter.fedora_version >= 6.5
            expect(adapter.pair_path(id)).to eq('ab/cd/ef/-g')
          else
            expect(adapter.pair_path(id)).to eq('ab/cd/ef')
          end
        end
        it "creates pairs until the first slash" do
          if adapter.fedora_version >= 6.5
            expect(adapter.pair_path('admin_set/default')).to eq('ad/mi/n_/se')
          else
            expect(adapter.pair_path('admin_set/default')).to eq('ad/mi/n_/se/t')
          end
        end
      end

      describe "#id" do
        it "creates an md5 hash from the connection_prefix" do
          expected = Digest::MD5.hexdigest adapter.connection_prefix
          expect(adapter.id.to_s).to eq expected
        end
      end
    end
  end
  context "fedora >= 6.5 with a non-standard pairtree count and length" do
    let(:version) { 6.5 }
    let(:fedora_pairtree_count) { 6 }
    let(:fedora_pairtree_length) { 1 }
    let(:adapter) do
      described_class.new(**fedora_adapter_config(base_path: "test_fed", fedora_version: version,
                                                  fedora_pairtree_count: fedora_pairtree_count,
                                                  fedora_pairtree_length: fedora_pairtree_length))
    end
    it_behaves_like "a Valkyrie::MetadataAdapter"
    it "creates the right pairtree segments" do
      expect(adapter.pair_path('abcdefghijkl')).to eq('a/b/c/d/e/f')
    end
  end
end
