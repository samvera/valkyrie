# frozen_string_literal: true
class ORMSyncer
  delegate :orm_attributes, :model_attributes, to: :attribute_mapper
  attr_reader :model
  def initialize(model:)
    @model = model
  end

  def sync!
    orm_object.metadata.merge!(clean_attributes)
  end

  def save
    sync! && orm_object.save! && rebuild_model
  end

  private

    def attribute_mapper
      AttributeMapper.new(orm_object: orm_object, model: model)
    end

    def orm_object
      @orm_object ||= ResourceFactory.from_model(model)
    end

    def rebuild_model
      @model = ResourceFactory.from_orm(orm_object)
    end

    def clean_attributes
      model_attributes.except(:id)
    end
end
