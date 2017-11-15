# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "dashboard/index.html.erb" do
  let(:my_first_book)  { create(:book, title: "My first book") }
  let(:my_second_book) { create(:book, title: "My second book") }

  before do
    assign(:documents, [my_second_book, my_first_book])
    render
  end

  it "displays a listing of the items a user has deposited" do
    expect(rendered).to have_content("works1")
  end
end
