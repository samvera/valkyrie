# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  subject { described_class.new(solr_hash) }
  let(:solr_hash) { Mapper.find(book).to_h }
  let(:book) { Book.new }

  describe "#members" do
    context "when the book has members" do
      let(:book) { Persister.save(Book.new(member_ids: Persister.save(Book.new).id)) }
      it "returns them" do
        expect(subject.members.first.id).not_to eq book.id
      end
    end
  end

  describe "#member_ids" do
    context "when the book has members" do
      let(:book) { Persister.save(Book.new(member_ids: Persister.save(Book.new).id)) }
      it "returns them" do
        expect(subject.member_ids).to eq book.member_ids
      end
    end
  end
end
