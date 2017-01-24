# frozen_string_literal: true
class FindByIdQuery
  attr_reader :klass, :id
  def initialize(klass, id)
    @klass = klass
    @id = id
  end

  def run
    klass.new(mapper.new(orm_model.find(id)).attributes)
  rescue ActiveRecord::RecordNotFound
    raise Persister::ObjectNotFoundError
  end

  private

    def orm_model
      ORM::Resource
    end

    def mapper
      ORMToObjectMapper
    end
end
