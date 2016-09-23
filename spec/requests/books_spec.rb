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
      id = response.location.gsub("http://www.example.com/catalog/", "")
      expect(find_book(id).title).to eq ["One", "Two"]
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
      it "saves it and redirects" do
        patch book_path(id: book.id), params: { book: { title: ["Two"] } }
        expect(response).to be_redirect
        expect(response.location).to eq solr_document_url(id: book.id)
        get response.location
        expect(response.body).to have_content "Two"
      end
    end
  end

  def find_book(id)
    FindByIdQuery.new(Book, id).run
  end
end
