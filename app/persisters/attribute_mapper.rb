# frozen_string_literal: true
class AttributeMapper
  attr_reader :model, :orm_object
  def initialize(model: nil, orm_object: nil)
    @model = model
    @orm_object = orm_object
  end

  def orm_attributes
    orm_object.attributes.merge(orm_object.metadata)
  end

  delegate :attributes, to: :model, prefix: true
end
