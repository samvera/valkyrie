# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController do
  let(:persister) { Valkyrie::Adapter.find(:indexing_persister).persister }
  describe "nested catalog paths" do
    it "loads the parent document when given an ID" do
      child = persister.save(model: Book.new)
      parent = persister.save(model: Book.new(member_ids: child.id))

      get :show, params: { parent_id: parent.id, id: child.id }

      expect(assigns(:parent_document)).not_to be_nil
    end
  end

  describe "#index" do
    it "finds all documents" do
      persister.save(model: Book.new)

      get :index, params: { search_field: "all_fields" }

      expect(assigns(:document_list).length).to eq 1
    end
  end
end
