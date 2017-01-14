# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController do
  describe "nested catalog paths" do
    let(:persister) { Indexer.new(Persister) }
    it "loads the parent document when given an ID" do
      child = persister.save(Book.new)
      parent = persister.save(Book.new(member_ids: child.id))

      get :show, params: { parent_id: "book_#{parent.id}", id: "book_#{child.id}" }

      expect(assigns(:parent_document)).not_to be_nil
    end
  end
end
