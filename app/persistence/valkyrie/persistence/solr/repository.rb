# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Repository
    attr_reader :model, :connection
    def initialize(model:, connection:)
      @model = model
      @connection = connection
    end

    def persist
      generate_id if model.id.blank?
      connection.add solr_document, params: { softCommit: true }
      model
    end

    def solr_document
      ::Valkyrie::Persistence::Solr::ResourceFactory.from_model(model).to_h
    end

    def inner_model
      if model.respond_to?(:model)
        model.model
      else
        model
      end
    end

    def generate_id
      Rails.logger.warn "The Solr adapter is not meant to persist new resources, but is now generating an ID."
      inner_model.id = SecureRandom.uuid
    end
  end
end
