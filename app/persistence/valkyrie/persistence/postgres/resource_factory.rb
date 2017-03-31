# frozen_string_literal: true
module Penguin::Persistence::Postgres
  class ResourceFactory
    class << self
      def to_model(orm_object)
        ::Penguin::Persistence::Postgres::DynamicKlass.new(orm_object.all_attributes)
      end

      def from_model(resource)
        ::Penguin::Persistence::Postgres::ORM::Resource.find_or_initialize_by(id: resource.id).tap do |orm_object|
          orm_object.model_type ||= resource.resource_class.to_s
          orm_object.metadata.merge!(resource.attributes.except(:id))
        end
      end

      def adapter
        Penguin::Persistence::Postgres
      end
    end
  end
end
