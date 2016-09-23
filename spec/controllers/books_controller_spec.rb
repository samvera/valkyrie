# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BooksController do
  describe "GET /books/new" do
    it "renders a form with a new book" do
      get :new

      expect(response).to be_success
    end
  end
end
