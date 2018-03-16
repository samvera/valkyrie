# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  # Responsible for converting a {Valkyrie::Resource} into a
  # {Valkyrie::Persistence::Postgres::ORM::Resource}
  class ResourceConverter
    delegate :orm_class, to: :resource_factory
    attr_reader :resource, :resource_factory
    def initialize(resource, resource_factory:)
      @resource = resource
      @resource_factory = resource_factory
    end

    def convert!
      orm_class.find_or_initialize_by(id: resource.id && resource.id.to_s).tap do |orm_object|
        orm_object.internal_resource = resource.internal_resource
        orm_object.alternate_identifier = resource.alternate_identifier if resource.respond_to?(:alternate_identifier)
        orm_object.metadata.merge!(resource.attributes.except(:id, :internal_resource, :created_at, :updated_at, :alternate_identifier))
      end
    end
  end
end
