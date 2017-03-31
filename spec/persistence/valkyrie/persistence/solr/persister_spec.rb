# frozen_string_literal: true
require 'rails_helper'
require 'penguin/specs/shared_specs'

RSpec.describe Penguin::Persistence::Solr::Persister do
  let(:persister) { Penguin::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection).persister }
  it_behaves_like "a Penguin::Persister"

  context "when given additional persisters" do
    let(:adapter) { Penguin::Persistence::Solr::Adapter.new(connection: Blacklight.default_index.connection, resource_indexer: indexer) }
    let(:indexer) { ResourceIndexer }
    before do
      class ResourceIndexer
        attr_reader :resource
        def initialize(resource:)
          @resource = resource
        end

        def to_solr
          {
            "combined_title_ssim" => resource.title + resource.other_title
          }
        end
      end
      class Resource
        include Penguin::ActiveModel
        attribute :id, String
        attribute :title, UniqueNonBlankArray
        attribute :other_title, UniqueNonBlankArray
      end
    end
    after do
      Object.send(:remove_const, :ResourceIndexer)
      Object.send(:remove_const, :Resource)
    end
    it "can add custom indexing" do
      b = Resource.new(title: ["Test"], other_title: ["Author"])
      expect(adapter.resource_factory.from_model(b)["combined_title_ssim"]).to eq ["Test", "Author"]
    end
  end
end
