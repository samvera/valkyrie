# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class QueryService
    attr_reader :connection, :resource_factory
    def initialize(connection:, resource_factory:)
      @connection = connection
      @resource_factory = resource_factory
    end

    def find_by(id:)
      Valkyrie::Persistence::Solr::Queries::FindByIdQuery.new(id, connection: connection, resource_factory: resource_factory).run
    end

    def find_all
      Valkyrie::Persistence::Solr::Queries::FindAllQuery.new(connection: connection, resource_factory: resource_factory).run
    end

    def find_all_of_model(model:)
      Valkyrie::Persistence::Solr::Queries::FindAllQuery.new(connection: connection, resource_factory: resource_factory, model: model).run
    end

    def find_parents(model:)
      find_inverse_references_by(model: model, property: :member_ids)
    end

    def find_members(model:)
      Valkyrie::Persistence::Solr::Queries::FindMembersQuery.new(model: model, connection: connection, resource_factory: resource_factory).run
    end

    def find_references_by(model:, property:)
      Valkyrie::Persistence::Solr::Queries::FindReferencesQuery.new(model: model, property: property, connection: connection, resource_factory: resource_factory).run
    end

    def find_inverse_references_by(model:, property:)
      Valkyrie::Persistence::Solr::Queries::FindInverseReferencesQuery.new(model: model, property: property, connection: connection, resource_factory: resource_factory).run
    end
  end
end
