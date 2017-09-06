# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/_admin_tools.html.erb" do
  let(:persister) { Valkyrie.config.metadata_adapter.persister }

  before do
    render 'catalog/admin_tools', document: document
  end

  context 'for a book' do
    let(:document) { instance_double(SolrDocument, resource: resource, book?: true, resource_id: 'abc123') }
    let(:resource) { persister.save(resource: Book.new(title: "Title")) }

    it "displays book tools" do
      expect(response).to have_button "Add Child"
      expect(response).to have_link "File Manager"
    end
  end

  context 'for a collection' do
    let(:document) { instance_double(SolrDocument, resource: resource, book?: false) }
    let(:resource) { persister.save(resource: Collection.new(title: "Title")) }

    it "does not display book tools" do
      expect(response).not_to have_button "Add Child"
      expect(response).not_to have_link "File Manager"
    end
  end
end
