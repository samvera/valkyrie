# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class ResourceFactory
    class << self
      def to_model(orm_object)
        ::Valkyrie::Persistence::Postgres::DynamicKlass.new(::Valkyrie::Persistence::Postgres::AttributeMapper.new(orm_object: orm_object).orm_attributes)
      end

      def from_model(resource)
        ::Valkyrie::Persistence::Postgres::ORM::Resource.find_or_initialize_by(id: resource.id).tap do |orm_object|
          orm_object.model_type ||= resource.class.to_s
        end
      end
    end
  end
end
