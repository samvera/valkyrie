# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/_children_collection.html.erb" do
  let(:document) { instance_double(SolrDocument, resource: resource, members: [child]) }
  let(:resource) { persister.save(resource: Book.new(title: "Title")) }
  let(:persister) { Valkyrie.config.metadata_adapter.persister }
  let(:child) { persister.save(resource: Book.new(title: "Child", a_member_of: resource.id)).decorate }

  before do
    assign(:document, document)
    child
    render
  end

  it "displays all members of the resource" do
    expect(response).to have_link "Child"
    expect(response).not_to have_link "[\"Child\"]"
  end
end
