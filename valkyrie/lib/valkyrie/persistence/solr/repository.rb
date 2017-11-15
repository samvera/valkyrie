# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Repository
    attr_reader :resources, :connection, :resource_factory, :commit_params

    def initialize(resources:, connection:, resource_factory:, commit_params:)
      @resources = resources
      @connection = connection
      @resource_factory = resource_factory
      @commit_params = commit_params
    end

    def persist
      documents = resources.map do |resource|
        generate_id(resource) if resource.id.blank?
        solr_document(resource)
      end
      connection.add documents, params: commit_params
      documents.map do |document|
        resource_factory.to_resource(object: document.stringify_keys)
      end
    end

    def delete
      connection.delete_by_id resources.map { |resource| resource.id.to_s }, params: commit_params
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
