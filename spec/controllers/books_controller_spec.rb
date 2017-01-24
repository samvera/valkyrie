# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BooksController do
  describe "GET /books/new" do
    it "renders a form with a new book" do
      get :new

      expect(response).to be_success
    end
  end

  describe "GET /books/:id/append/book" do
    it "renders a form to append a child book" do
      parent = Persister.save(Book.new)
      get :append, params: { id: parent.id, model: Book }

      expect(assigns(:form).append_id).to eq parent.id
    end
  end

  describe "GET /books/:id/append/page" do
    it "renders a form to append a child page" do
      parent = Persister.save(Page.new)
      get :append, params: { id: parent.id, model: Page }

      expect(assigns(:form).class).to eq PageForm
      expect(assigns(:form).append_id).to eq parent.id
    end
  end

  describe "GET /books/:id/file_manager" do
    it "sets the record and children variables" do
      child = Persister.save(Book.new)
      parent = Persister.save(Book.new(member_ids: child.id))

      get :file_manager, params: { id: parent.id }

      expect(assigns(:record).id).to eq parent.id
      expect(assigns(:children).map(&:id)).to eq [child.id]
    end
  end
end
