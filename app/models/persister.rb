# frozen_string_literal: true
class Persister
  @cache = {}
  class << self
    attr_reader :cache
    def save(model)
      book_attributes = model.attributes
      book_attributes.delete(:id) if book_attributes[:id].blank?
      book_attributes = {id: NoBrainer::Document::PrimaryKey::Generator.generate}.merge(book_attributes)
      book = ORM::Book.upsert(book_attributes)
      model = model.class.new(book.attributes)
      model
    end
  end
  class ObjectNotFoundError < StandardError
  end
end
