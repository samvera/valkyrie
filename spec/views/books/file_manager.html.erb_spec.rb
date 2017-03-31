# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "books/file_manager.html.erb", type: :view do
  let(:members) { [member] }
  let(:member) { BookForm.new(Persister.save(model: Book.new)) }
  let(:parent) { BookForm.new(Persister.save(model: Book.new(title: "Test title", member_ids: members.map(&:id)))) }

  before do
    assign(:record, parent)
    assign(:children, members)
    render
  end

  it "has a bulk edit header" do
    expect(rendered).to include "<h1>File Manager</h1>"
  end

  it "displays each book's title" do
    expect(rendered).to have_selector "input[name='book[title][]'][type='text'][value='#{member.title.first}']"
  end

  it "has a link to edit each file set" do
    expect(rendered).to have_selector("a[href=\"#{ContextualPath.new(member.id, parent.id).show}\"]")
  end

  it "has a link back to parent" do
    expect(rendered).to have_link "Test title", href: "/catalog/#{CGI.escape(parent.id)}"
  end

  it "renders a form for each member" do
    expect(rendered).to have_selector("#sortable form", count: members.length)
  end

  it "renders an input for titles" do
    expect(rendered).to have_selector("input[name='book[title][]']")
  end

  it "renders a resource form for the entire resource" do
    expect(rendered).to have_selector("form#resource-form")
  end
end
