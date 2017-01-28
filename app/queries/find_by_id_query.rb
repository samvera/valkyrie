# frozen_string_literal: true
class FindByIdQuery
  attr_reader :klass, :id
  def initialize(klass, id)
    @klass = klass
    @id = id
  end

  def run
    ResourceFactory.from_orm(relation)
  rescue ActiveRecord::RecordNotFound
    raise Persister::ObjectNotFoundError
  end

  private

    def relation
      orm_model.find(id)
    end

    def orm_model
      ORM::Resource
    end

    def mapper
      ORMToObjectMapper
    end
end
