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

  attr_reader :model, :mapper, :orm_model

  def initialize(model:, mapper:, orm_model: ORM::Book)
    @model = model
    @mapper = mapper
    @orm_model ||= orm_model
  end

  def persist
    mapper_instance.apply!(clean_book_attributes)
    orm_object.save
    @model = model.class.new(mapper_instance.attributes)
  end

  private

    def book_attributes
      @book_attributes ||= model.attributes
    end

    def orm_object
      @orm_object ||= orm_model.first_or_initialize(id: id)
    end

    def clean_book_attributes
      @clean_book_attributes ||= book_attributes.except(:id)
    end

    def mapper_instance
      @mapper_instance ||= mapper.new(orm_object)
    end

    def id
      @id ||= book_attributes[:id].present? ? book_attributes[:id] : nil
    end
end
