# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/_members_default.html.erb" do
  let(:document) { instance_double(SolrDocument, id: "bla", members: [child], member_ids: [child.id]) }
  let(:persister) { Valkyrie.config.metadata_adapter.persister }
  let(:child) { persister.save(resource: FileSet.new(title: "Child", member_ids: [file_node.id])).decorate }
  let(:file_node) { persister.save(resource: FileNode.new) }

  before do
    assign(:document, document)
    child
    render partial: "catalog/members_default", locals: { document: document }
  end

  it "displays the title of the children" do
    expect(response).to have_content "Child"
    expect(response).to have_link "Download"
  end
end
