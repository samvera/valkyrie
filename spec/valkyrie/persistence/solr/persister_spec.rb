# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Solr::Persister do
  let(:connection) { Blacklight.default_index.connection }
  let(:persister) { Valkyrie::Persistence::Solr::Adapter.new(connection: connection).persister }

  it_behaves_like "a Valkyrie::Persister"

  context "when given additional persisters" do
    let(:adapter) { Valkyrie::Persistence::Solr::Adapter.new(connection: connection, resource_indexer: indexer_class) }
    let(:resource_class) do
      Class.new(Valkyrie::Model) do
        attribute :id, String
        attribute :title, Valkyrie::Types::Set
        attribute :other_title, Valkyrie::Types::Set
      end
    end
    let(:indexer_class) do
      Class.new do
        attr_reader :resource
        def initialize(resource:)
          @resource = resource
        end

        def to_solr
          { "combined_title_ssim" => resource.title + resource.other_title }
        end
      end
    end

    it "can add custom indexing" do
      b = resource_class.new(title: ["Test"], other_title: ["Author"])
      expect(adapter.resource_factory.from_model(b)["combined_title_ssim"]).to eq ["Test", "Author"]
    end
  end

  context "when told to index a really long string" do
    let(:adapter) { Valkyrie::Persistence::Solr::Adapter.new(connection: connection) }
    it "works" do
      b = Book.new(title: "a" * 100_000)
      expect { adapter.persister.save(model: b) }.not_to raise_error
    end
  end
end
