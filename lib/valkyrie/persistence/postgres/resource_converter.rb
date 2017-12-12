# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
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
        orm_object.metadata.merge!(resource.attributes.except(:id, :internal_resource, :created_at, :updated_at))
      end
    end
  end
end
