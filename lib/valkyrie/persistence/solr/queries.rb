# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  module Queries
    MEMBER_IDS = 'member_ids_ssim'
    MODEL = 'internal_resource_ssim'
    require 'valkyrie/persistence/solr/queries/default_paginator'
    require 'valkyrie/persistence/solr/queries/find_all_query'
    require 'valkyrie/persistence/solr/queries/find_by_id_query'
    require 'valkyrie/persistence/solr/queries/find_inverse_references_query'
    require 'valkyrie/persistence/solr/queries/find_members_query'
    require 'valkyrie/persistence/solr/queries/find_references_query'

    # @api private
    def self.run_find_by_id_query(id, connection:, resource_factory:)
      FindByIdQuery.new(id, connection: connection, resource_factory: resource_factory).run
    end

    # @api private
    def self.run_find_all_query(connection:, resource_factory:, model: nil)
      FindAllQuery.new(connection: connection, resource_factory: resource_factory, model: model).run
    end

    # @api private
    def self.run_find_members(resource:, model: nil, connection:, resource_factory:)
      FindMembersQuery.new(resource: resource, model: model, connection: connection, resource_factory: resource_factory).run
    end

    # @api private
    def self.run_find_references_query(resource:, property:, connection:, resource_factory:)
      FindReferencesQuery.new(resource: resource, property: property, connection: connection, resource_factory: resource_factory).run
    end

    # @api private
    def self.run_find_inverse_references_query(resource:, property:, connection:, resource_factory:)
      FindInverseReferencesQuery.new(resource: resource, property: property, connection: connection, resource_factory: resource_factory).run
    end
  end
end
