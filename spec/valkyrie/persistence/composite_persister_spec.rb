# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::CompositePersister do
  let(:adapter) { Valkyrie::Persistence::Memory::MetadataAdapter.new }
  let(:query_service) { adapter.query_service }
  let(:persister) do
    described_class.new(
      adapter.persister,
      Valkyrie::Persistence::Memory::MetadataAdapter.new.persister
    )
  end
  it_behaves_like "a Valkyrie::Persister"

  context 'with postgres and solr' do
    let(:client) { RSolr.connect(url: SOLR_TEST_URL) }
    let(:persister) do
      described_class.new(
        Valkyrie::Persistence::Postgres::MetadataAdapter.new.persister,
        adapter.persister
      )
    end
    let(:adapter) { Valkyrie::Persistence::Solr::MetadataAdapter.new(connection: client) }

    before do
      class CustomResource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :CustomResource)
    end

    it "can find the object in the solr persister" do
      book = persister.save(resource: CustomResource.new)
      expect { query_service.find_by(id: book.id) }.not_to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
    end
  end
end
