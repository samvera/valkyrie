# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Persister do
  describe ".save" do
    it "saves a book and returns it with a UUID" do
      book = Book.new(title: "Test")

      output = described_class.save(book)

      expect(output.id).not_to be_blank
    end

    it "persists the model it was saved as" do
      book = Book.new(title: "Test")

      described_class.save(book)

      expect(ORM::Resource.where(model_type: "Book").length).to eq 1
    end

    it "doesn't override a book that already has an ID" do
      book = described_class.save(Book.new(title: "Test"))
      id = book.id

      output = described_class.save(book)

      expect(output.id).to eq id
    end

    it "can be found after being persisted" do
      book = Book.new(title: "Test")

      output = described_class.save(book)

      expect(find_book(output.id).to_h).to eq output.to_h
    end

    it "can persist a form object" do
      book = Book.new
      form = BookForm.new(book)

      output = described_class.save(form)

      expect(output.id).not_to be_blank
    end
  end

  def find_book(id)
    FindByIdQuery.new(Book, id).run
  end
end
