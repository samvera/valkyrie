# frozen_string_literal: true
class Persister
  @cache = {}
  class << self
    attr_reader :cache
    def save(model)
      new(model: model, mapper: mapper).persist
    end

    def mapper
      ORMToObjectMapper
    end
  end
  class ObjectNotFoundError < StandardError
  end

  attr_reader :model, :mapper

  def initialize(model:, mapper:)
    @model = model
    @mapper = mapper
  end

  def persist
    book = ORM::Book.first_or_initialize(id: id)
    mapper_instance = mapper.new(book)
    mapper_instance.apply!(clean_book_attributes)
    book.save
    @model = model.class.new(mapper_instance.attributes)
  end

  private

    def book_attributes
      @book_attributes ||= model.attributes
    end

    def clean_book_attributes
      @clean_book_attributes ||= book_attributes.except(:id)
    end

    def id
      @id ||= book_attributes[:id].present? ? book_attributes[:id] : nil
    end
end
