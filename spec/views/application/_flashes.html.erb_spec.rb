require 'rails_helper'

RSpec.describe "application/_flashes.html.erb" do
  it "renders user facing flashes" do
    flash[:alert] = "Test"
    render
    expect(rendered).to have_content "Test"
  end
end
