# frozen_string_literal: true
class Persister
  @cache = {}
  class << self
    attr_reader :cache
    def save(model)
      book_attributes = model.attributes
      book_attributes.delete(:id) if book_attributes[:id].blank?
      id = book_attributes.delete(:id)
      book = ORM::Book.first_or_initialize(id: id)
      mapper = self.mapper.new(book)
      mapper.apply!(book_attributes)
      book.save
      model = model.class.new(mapper.attributes)
      model
    end

    def mapper
      ORMToObjectMapper
    end
  end
  class ObjectNotFoundError < StandardError
  end
end
