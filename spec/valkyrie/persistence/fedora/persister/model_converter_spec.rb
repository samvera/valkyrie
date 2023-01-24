# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Fedora::Persister::ModelConverter do
  [4, 5, 6].each do |fedora_version|
    context "fedora #{fedora_version}" do
      let(:version) { fedora_version }
      let(:adapter) do
        Valkyrie::Persistence::Fedora::MetadataAdapter.new(
          **fedora_adapter_config(base_path: "test_fed", schema: schema, fedora_version: version)
        )
      end

      let(:resource)  { SampleResource.new(title: "My Title") }
      let(:converter) { described_class.new(resource: resource, adapter: adapter) }

      before do
        class SampleResource < Valkyrie::Resource
          include Valkyrie::Resource::AccessControls
          attribute :title
        end
      end

      after do
        Object.send(:remove_const, :SampleResource)
      end

      context "with the default schema" do
        let(:schema) { Valkyrie::Persistence::Fedora::PermissiveSchema.new }
        let(:query)  { converter.convert.graph.query([nil, RDF::URI("http://example.com/predicate/title"), nil]) }

        it "persists to Fedora using a fake predicate" do
          expect(query.first.object.to_s).to eq("My Title")
        end
      end

      context "with a defined schema" do
        let(:schema) { Valkyrie::Persistence::Fedora::PermissiveSchema.new(title: ::RDF::Vocab::DC.title) }
        let(:query)  { converter.convert.graph.query([nil, ::RDF::Vocab::DC.title, nil]) }

        it "persists to Fedora using the defined predicate" do
          expect(query.first.object.to_s).to eq("My Title")
        end
      end
    end
  end
end
