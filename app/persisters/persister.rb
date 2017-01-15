# frozen_string_literal: true
class Persister
  @cache = {}
  class << self
    attr_reader :cache
    def save(model)
      return FormPersister.new(form: model, mapper: mapper).persist if model.respond_to?(:model)
      new(model: model, mapper: mapper).persist
    end

    def mapper
      ORMToObjectMapper
    end
  end
  class ObjectNotFoundError < StandardError
  end

  attr_reader :model, :mapper, :orm_model, :post_processors

  def initialize(model:, mapper:, post_processors: [], orm_model: ORM::Book)
    @model = model
    @mapper = mapper
    @orm_model ||= orm_model
    @post_processors ||= post_processors
  end

  def persist
    mapper_instance.apply!(clean_book_attributes)
    orm_object.save
    @model = model.class.new(mapper_instance.attributes)
    post_processors.each do |processor|
      processor.new(persister: self).run
    end
    model
  end

  private

    def book_attributes
      @book_attributes ||= model.attributes
    end

    def orm_object
      @orm_object ||= orm_model.find_or_initialize_by(id: id)
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
