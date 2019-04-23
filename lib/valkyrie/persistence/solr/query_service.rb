# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  require 'valkyrie/persistence/solr/queries'
  # Query Service for Solr MetadataAdapter.
  class QueryService
    attr_reader :connection, :resource_factory, :adapter
    # @param [RSolr::Client] connection
    # @param [Valkyrie::Persistence::Solr::ResourceFactory] resource_factory
    def initialize(connection:, resource_factory:, adapter:)
      @connection = connection
      @resource_factory = resource_factory
      @adapter = adapter
    end

    # Find resources by Valkyrie ID
    # @param [Valkyrie::ID] id
    # @return [Valkyrie::Resource]
    def find_by(id:)
      id = Valkyrie::ID.new(id.to_s) if id.is_a?(String)
      validate_id(id)
      Valkyrie::Persistence::Solr::Queries::FindByIdQuery.new(id, connection: connection, resource_factory: resource_factory).run
    end

    # Find resources by a Valkyrie alternate identifier
    # @param [Valkyrie::ID] alternate_identifier
    # @return [Valkyrie::Resource]
    def find_by_alternate_identifier(alternate_identifier:)
      alternate_identifier = Valkyrie::ID.new(alternate_identifier.to_s) if alternate_identifier.is_a?(String)
      validate_id(alternate_identifier)
      Valkyrie::Persistence::Solr::Queries::FindByAlternateIdentifierQuery.new(alternate_identifier, connection: connection, resource_factory: resource_factory).run
    end

    # Find resources using a set of Valkyrie IDs
    # @param [Array<Valkyrie::ID>] ids
    # @return [Array<Valkyrie::Resource>]
    def find_many_by_ids(ids:)
      ids.map! do |id|
        id = Valkyrie::ID.new(id.to_s) if id.is_a?(String)
        validate_id(id)
        id
      end
      Valkyrie::Persistence::Solr::Queries::FindManyByIdsQuery.new(ids, connection: connection, resource_factory: resource_factory).run
    end

    # Find all of the Valkyrie Resources persisted in the Solr index
    # @return [Array<Valkyrie::Resource>]
    def find_all
      Valkyrie::Persistence::Solr::Queries::FindAllQuery.new(connection: connection, resource_factory: resource_factory).run
    end

    # Find all of the Valkyrie Resources of a model persisted in the Solr index
    # @param [Class, String] model the Valkyrie::Resource Class
    # @return [Array<Valkyrie::Resource>]
    def find_all_of_model(model:)
      Valkyrie::Persistence::Solr::Queries::FindAllQuery.new(connection: connection, resource_factory: resource_factory, model: model).run
    end

    # Find all of the parent resources for a given Valkyrie Resource
    # @param [Valkyrie::Resource] member resource
    # @return [Array<Valkyrie::Resource>] parent resources
    def find_parents(resource:)
      find_inverse_references_by(resource: resource, property: :member_ids)
    end

    # Find all of the member resources for a given Valkyrie Resource
    # @param [Valkyrie::Resource] parent resource
    # @return [Array<Valkyrie::Resource>] member resources
    def find_members(resource:, model: nil)
      Valkyrie::Persistence::Solr::Queries::FindMembersQuery.new(
        resource: resource,
        model: model,
        connection: connection,
        resource_factory: resource_factory
      ).run
    end

    # Find all of the resources referenced by a given Valkyrie Resource using a specific property
    # @param [Valkyrie::Resource] resource
    # @param [Symbol, String] property
    # @return [Array<Valkyrie::Resource>] referenced resources
    def find_references_by(resource:, property:)
      if ordered_property?(resource: resource, property: property)
        Valkyrie::Persistence::Solr::Queries::FindOrderedReferencesQuery.new(resource: resource, property: property, connection: connection, resource_factory: resource_factory).run
      else
        Valkyrie::Persistence::Solr::Queries::FindReferencesQuery.new(resource: resource, property: property, connection: connection, resource_factory: resource_factory).run
      end
    end

    # Find all of the resources referencing a given Valkyrie Resource using a specific property
    # (e. g. find all resources referencing a parent resource as a collection using the property "member_of_collections")
    # @param [Valkyrie::Resource] referenced resource
    # @param [Symbol, String] property
    # @return [Array<Valkyrie::Resource>] related resources
    def find_inverse_references_by(resource: nil, id: nil, property:)
      raise ArgumentError, "Provide resource or id" unless resource || id
      ensure_persisted(resource) if resource
      id ||= resource.id
      Valkyrie::Persistence::Solr::Queries::FindInverseReferencesQuery.new(id: id, property: property, connection: connection, resource_factory: resource_factory).run
    end

    # Construct the Valkyrie::Persistence::CustomQueryContainer object using this query service
    # @return [Valkyrie::Persistence::CustomQueryContainer]
    def custom_queries
      @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
    end

    private

      # Determine whether or not a value is a Valkyrie ID
      # @param [Object] id
      # @return [Boolean]
      def validate_id(id)
        raise ArgumentError, 'id must be a Valkyrie::ID' unless id.is_a? Valkyrie::ID
      end

      # Ensure that a given Valkyrie Resource has been persisted
      # @param [Valkyrie::Resource] resource
      def ensure_persisted(resource)
        raise ArgumentError, 'resource is not saved' unless resource.persisted?
      end

      def ordered_property?(resource:, property:)
        resource.class.schema.key(property).type.meta.try(:[], :ordered)
      end
  end
end
