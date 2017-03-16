# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Book Management" do
  describe "new" do
    it "has a form for creating books" do
      get "/books/new"
      expect(response.body).to have_field "Title"
      expect(response.body).to have_button "Create Book"
    end
  end

  describe "create" do
    it "can create a book with two titles" do
      post "/books", params: { book: { title: ["One", "Two"] } }
      expect(response).to be_redirect
      expect(response.location).to start_with "http://www.example.com/catalog/"
      id = response.location.gsub("http://www.example.com/catalog/", "").gsub("%2F", "/")
      expect(find_book(id).title).to contain_exactly "One", "Two"
    end
    it "renders the form if it doesn't create a book" do
      post "/books", params: { book: { test: ["1"] } }
      expect(response.body).to have_field "Title"
    end
    it "can create a book as a child of another" do
      post "/books", params: { book: { title: ["One", "Two"] } }
      id = response.location.gsub("http://www.example.com/catalog/", "").gsub("%2F", "/")
      post "/books", params: { book: { title: ["Child"], append_id: id } }
      parent_book = find_book(id)
      expect(parent_book.member_ids).not_to be_blank

      expect(request).to redirect_to parent_solr_document_path(parent_id: id, id: parent_book.member_ids.first)
    end
  end

  describe "destroy" do
    it "can delete a book" do
      book = Persister.save(Book.new(title: "Test"))
      delete "/books/#{book.id}"

      expect(response).to redirect_to root_path
      expect { QueryService.find_by_id(book.id) }.to raise_error ::Persister::ObjectNotFoundError
    end
  end

  describe "edit" do
    context "when a book doesn't exist" do
      it "raises an error" do
        expect { get edit_book_path(id: "test") }.to raise_error(Persister::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      let(:book) { Persister.save(Book.new(title: ["Testing"])) }
      it "renders a form" do
        get edit_book_path(id: book.id)
        expect(response.body).to have_field "Title", with: "Testing"
        expect(response.body).to have_button "Update Book"
      end
    end
  end

  describe "update" do
    context "when a bookd oesn't exist" do
      it "raises an error" do
        expect { patch book_path(id: "test") }.to raise_error(Persister::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      let(:book) { Persister.save(Book.new(title: ["Testing"])) }
      let(:solr_adapter) { Valkyrie::Adapter.find(:index_solr) }
      it "saves it and redirects" do
        patch book_path(id: book.id), params: { book: { title: ["Two"] } }
        expect(response).to be_redirect
        expect(response.location).to eq solr_document_url(id: solr_adapter.resource_factory.from_model(book).id)
        get response.location
        expect(response.body).to have_content "Two"
      end
      it "renders the form if it fails validations" do
        patch book_path(id: book.id), params: { book: { title: [""] } }
        expect(response.body).to have_field "Title"
      end
    end
  end

  def find_book(id)
    QueryService.find_by_id(id)
  end
end
