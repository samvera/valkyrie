# frozen_string_literal: true
class ORMToObjectMapper
  attr_reader :orm_model
  def initialize(orm_model)
    @orm_model = orm_model
  end

  def attributes
    orm_model.attributes.merge(orm_model.metadata)
  end
end
