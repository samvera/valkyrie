# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/_members_default.html.erb" do
  let(:document) { instance_double(SolrDocument, id: "bla", members: [child], member_ids: [child.id]) }
  let(:persister) { Valkyrie.config.adapter.persister }
  let(:child) { persister.save(model: FileSet.new(title: "Child", member_ids: [Valkyrie::ID.new("file_node_id")])).decorate }

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
