# frozen_string_literal: true
require 'valkyrie/persistence/postgres/queries'
module Valkyrie::Persistence::Postgres
  class QueryService
    attr_reader :adapter
    delegate :resource_factory, to: :adapter
    delegate :orm_class, to: :resource_factory
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_all)
    def find_all
      orm_class.all.lazy.map do |orm_object|
        resource_factory.to_resource(object: orm_object)
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_all_of_model)
    def find_all_of_model(model:)
      orm_class.where(internal_resource: model.to_s).lazy.map do |orm_object|
        resource_factory.to_resource(object: orm_object)
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_by)
    def find_by(id:)
      resource_factory.to_resource(object: orm_class.find(id))
    rescue ActiveRecord::RecordNotFound
      raise Valkyrie::Persistence::ObjectNotFoundError
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_members)
    def find_members(resource:)
      Valkyrie::Persistence::Postgres::Queries::FindMembersQuery.new(resource, resource_factory: resource_factory).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_parents)
    def find_parents(resource:)
      find_inverse_references_by(resource: resource, property: :member_ids)
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_references_by)
    def find_references_by(resource:, property:)
      Valkyrie::Persistence::Postgres::Queries::FindReferencesQuery.new(resource, property, resource_factory: resource_factory).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_inverse_references_by)
    def find_inverse_references_by(resource:, property:)
      Valkyrie::Persistence::Postgres::Queries::FindInverseReferencesQuery.new(resource, property, resource_factory: resource_factory).run
    end
  end
end
