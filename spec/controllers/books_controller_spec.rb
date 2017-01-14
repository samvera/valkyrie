# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BooksController do
  describe "GET /books/new" do
    it "renders a form with a new book" do
      get :new

      expect(response).to be_success
    end
  end

  describe "GET /books/:id/append" do
    it "renders a form to append a child book" do
      parent = Persister.save(Book.new)
      get :append, params: { id: parent.id }

      expect(assigns(:form).append_id).to eq parent.id
    end
  end
end
