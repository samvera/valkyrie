# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Repository
    COMMIT_PARAMS = { softCommit: true }.freeze

    attr_reader :resources, :connection, :resource_factory
    def initialize(resources:, connection:, resource_factory:)
      @resources = resources
      @connection = connection
      @resource_factory = resource_factory
    end

    def persist
      documents = resources.map do |resource|
        generate_id(resource) if resource.id.blank?
        solr_document(resource)
      end
      connection.add documents, params: COMMIT_PARAMS
      documents.map do |document|
        resource_factory.to_resource(object: document.stringify_keys)
      end
    end

    def delete
      connection.delete_by_id resources.map { |resource| resource.id.to_s }, params: COMMIT_PARAMS
      resources
    end

    def solr_document(resource)
      resource_factory.from_resource(resource: resource).to_h
    end

    def generate_id(resource)
      Valkyrie.logger.warn "The Solr adapter is not meant to persist new resources, but is now generating an ID."
      resource.id = SecureRandom.uuid
    end
  end
end
