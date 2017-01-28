# frozen_string_literal: true
class ResourceFactory
  class << self
    def from_orm(orm_object)
      DynamicKlass.new(AttributeMapper.new(orm_object: orm_object).orm_attributes)
    end

    def from_model(resource)
      ORM::Resource.find_or_initialize_by(id: resource.id).tap do |orm_object|
        orm_object.model_type ||= resource.class.to_s
      end
    end
  end
end
