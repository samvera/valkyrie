# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/queries'
  class QueryService
    attr_reader :connection, :resource_factory
    # @param connection [RSolr::Client]
    # @param resource_factory [Valkyrie::Persistence::Solr::ResourceFactory]
    def initialize(connection:, resource_factory:)
      @connection = connection
      @resource_factory = resource_factory
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_by)
    def find_by(id:)
      Valkyrie::Persistence::Solr::Queries::FindByIdQuery.new(id, connection: connection, resource_factory: resource_factory).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_all)
    def find_all
      Valkyrie::Persistence::Solr::Queries::FindAllQuery.new(connection: connection, resource_factory: resource_factory).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_all_of_model)
    def find_all_of_model(model:)
      Valkyrie::Persistence::Solr::Queries::FindAllQuery.new(connection: connection, resource_factory: resource_factory, model: model).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_parents)
    def find_parents(model:)
      find_inverse_references_by(model: model, property: :member_ids)
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_members)
    def find_members(model:)
      Valkyrie::Persistence::Solr::Queries::FindMembersQuery.new(model: model, connection: connection, resource_factory: resource_factory).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_references_by)
    def find_references_by(model:, property:)
      Valkyrie::Persistence::Solr::Queries::FindReferencesQuery.new(model: model, property: property, connection: connection, resource_factory: resource_factory).run
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_inverse_references_by)
    def find_inverse_references_by(model:, property:)
      Valkyrie::Persistence::Solr::Queries::FindInverseReferencesQuery.new(model: model, property: property, connection: connection, resource_factory: resource_factory).run
    end
  end
end
