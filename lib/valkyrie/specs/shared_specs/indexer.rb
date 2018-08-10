# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Indexer' do |*_flags|
  before do
    raise 'indexer must be set with `let(:indexer)`' unless
      defined? indexer

    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::Set
      attribute :author, Valkyrie::Types::Set
      attribute :birthday, Valkyrie::Types::DateTime.optional
      attribute :creator, Valkyrie::Types::String
    end
  end

  after do
    Object.send(:remove_const, :Resource)
  end

  let(:connection) { RSolr.connect(url: SOLR_TEST_URL) }
  let(:metadata_adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: connection, resource_indexer: indexer) }
  let(:created_at) { Time.now.utc }
  let(:attributes) do
    {
      created_at: created_at,
      internal_resource: 'Resource',
      title: ["Test", RDF::Literal.new("French", language: :fr)],
      author: ["Author"],
      creator: "Creator"
    }
  end
  let(:resource) do
    instance_double(Resource,
                    id: "1",
                    internal_resource: 'Resource',
                    attributes: attributes)
  end
  let(:model_converter) { Valkyrie::Persistence::Solr::ModelConverter.new(resource, resource_factory: metadata_adapter.resource_factory) }

  describe '#to_solr' do
    subject { model_converter.indexer_solr(resource) }

    it { is_expected.to be_a Hash }
  end
end
