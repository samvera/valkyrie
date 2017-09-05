# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  subject(:solr_document) { described_class.new(solr_hash) }
  let(:solr_adapter) { Valkyrie::MetadataAdapter.find(:index_solr) }
  let(:solr_hash) { solr_adapter.resource_factory.from_resource(resource: book).to_h }
  let(:book) { Book.new }

  describe "#members" do
    context "when the book has members" do
      let(:book) { Persister.save(resource: Book.new(member_ids: Persister.save(resource: Book.new).id)) }
      it "returns them" do
        expect(solr_document.members.first.id).not_to eq book.id
      end
    end
  end

  describe "#member_ids" do
    context "when the book has members" do
      let(:book) { Persister.save(resource: Book.new(member_ids: Persister.save(resource: Book.new).id)) }
      it "returns them" do
        expect(solr_document.member_ids).to eq book.member_ids
      end
    end
    context "when the book has non-ID members" do
      let(:book) { Book.new(id: "test", member_ids: [Persister.save(resource: Book.new).id, "1"]) }
      it "returns them" do
        expect(solr_document.member_ids).to eq book.member_ids
      end
    end
  end
end
