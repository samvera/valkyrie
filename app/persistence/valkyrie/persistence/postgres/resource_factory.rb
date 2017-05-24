# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class ResourceFactory
    class << self
      def to_model(orm_object)
        ::Valkyrie::Persistence::Postgres::DynamicKlass.new(orm_object.all_attributes)
      end

      def from_model(model, resource: nil)
        (resource || ::Valkyrie::Persistence::Postgres::ORM::Resource.find_or_initialize_by(id: model.id.to_s)).tap do |orm_object|
          orm_object.model_type ||= model.resource_class.to_s
          orm_object.metadata.merge!(model.attributes.except(:id))
        end
      end
    end
  end
end
