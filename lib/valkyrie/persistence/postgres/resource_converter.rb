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
        process_lock_token(orm_object)
        orm_object.metadata.merge!(attributes)
      end
    end

    def process_lock_token(orm_object)
      return unless resource.respond_to?(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
      postgres_token = resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK].find do |token|
        token.adapter_id == resource_factory.adapter_id
      end
      return unless postgres_token
      orm_object.lock_version = postgres_token.token
    end

    # Convert attributes to all be arrays to better enable querying and
    # "changing of minds" later on.
    def attributes
      Hash[
        resource.attributes.except(:id, :internal_resource, :created_at, :updated_at).compact.map do |k, v|
          [k, Array.wrap(v)]
        end
      ]
    end
  end
end
