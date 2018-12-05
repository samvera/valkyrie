# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::MetadataAdapter do
  [4, 5].each do |fedora_version|
    context "fedora #{fedora_version}" do
      let(:version) { fedora_version }
      let(:adapter) { described_class.new(fedora_adapter_config(base_path: "test_fed", fedora_version: version)) }
      it_behaves_like "a Valkyrie::MetadataAdapter"

      describe "#schema" do
        context "by default" do
          specify { expect(adapter.schema).to be_a Valkyrie::Persistence::Fedora::PermissiveSchema }
        end

        context "with a custom schema" do
          let(:adapter) { described_class.new(fedora_adapter_config(base_path: "test_fed", schema: "custom-schema", fedora_version: version)) }
          specify { expect(adapter.schema).to eq("custom-schema") }
        end
      end

      describe "#id_to_uri" do
        it "converts ids with a slash" do
          id = "test/default"
          if adapter.fedora_version == 4

            expect(adapter.id_to_uri(id).to_s).to eq "http://localhost:8988/rest/test_fed/te/st/test%2Fdefault"
          else
            expect(adapter.id_to_uri(id).to_s).to eq "http://localhost:8998/rest/test_fed/test%2Fdefault"
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
          expect(adapter.pair_path('abcdef-ghijkl')).to eq('ab/cd/ef')
        end
        it "creates pairs until the first slash" do
          expect(adapter.pair_path('admin_set/default')).to eq('ad/mi/n_/se/t')
        end
      end

      describe "#id" do
        it "creates an md5 hash from the connection_prefix" do
          expected = Digest::MD5.hexdigest adapter.connection_prefix
          expect(adapter.id.to_s).to eq expected
        end
      end

      # rubocop:disable Metrics/LineLength
      describe "#standardize_query_result?" do
        it "throws a deprecation warning when it's set to false" do
          allow(Valkyrie.config).to receive(:standardize_query_result).and_return(false)
          expect { adapter.standardize_query_result? }.to output(/Please enable query normalization to avoid inconsistent results between different adapters by adding `standardize_query_results: true` to your environment block in config\/valkyrie.yml. This will be the behavior in Valkyrie 2.0./).to_stderr
        end
      end
      # rubocop:enable Metrics/LineLength
    end
  end
end
