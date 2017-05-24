# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "shared/_site_actions.html.erb", type: :view do
  let(:user) { nil }
  before do
    sign_in user if user
    render
  end
  describe "admin functionality" do
    context "when not logged in" do
      it "does not show create links" do
        expect(rendered).not_to have_link "New Book", href: new_book_path
      end
    end
    context "when logged in as a user" do
      let(:user) { FactoryGirl.create(:user) }
      it "doesn't show create links" do
        expect(rendered).not_to have_link "New Book"
      end
    end
    context "when logged in as an admin" do
      let(:user) { FactoryGirl.create(:admin) }
      it "shows create links" do
        expect(rendered).to have_link "New Book", href: new_book_path
      end
    end
  end
end
