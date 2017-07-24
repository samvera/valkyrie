# frozen_string_literal: true
require 'valkyrie/persistence/postgres/dynamic_klass'
module Valkyrie::Persistence::Postgres
  class ResourceFactory
    class << self
      # @param orm_object [Valkyrie::Persistence::Postgres::ORM::Resource] AR
      #   record to be converted.
      # @return [Valkyrie::Resource] Model representation of the AR record.
      def to_resource(orm_object)
        ::Valkyrie::Persistence::Postgres::DynamicKlass.new(orm_object.all_attributes)
      end

      # @param resource [Valkyrie::Resource] Model to be converted to ActiveRecord.
      # @return [Valkyrie::Persistence::Postgres::ORM::Resource] ActiveRecord
      #   resource for the Valkyrie resource.
      def from_resource(resource)
        ::Valkyrie::Persistence::Postgres::ORM::Resource.find_or_initialize_by(id: resource.id.to_s).tap do |orm_object|
          orm_object.internal_resource = resource.internal_resource
          orm_object.metadata.merge!(resource.attributes.except(:id, :internal_resource, :created_at, :updated_at))
        end
      end
    end
  end
end
