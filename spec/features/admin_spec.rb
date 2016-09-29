# frozen_string_literal: true
require 'rails_helper'

feature "Administrative home page" do
  background do
    login_as FactoryGirl.create(:admin)
  end
  scenario "displaying the front page" do
    visit root_path
    expect(page).to have_link "New Book", href: new_book_path
  end
end
