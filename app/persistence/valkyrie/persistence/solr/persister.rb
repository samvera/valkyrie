# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Persister
    class << self
      def save(model)
        new(model: model).persist
      end

      def adapter
        Valkyrie::Persistence::Solr
      end
    end

    attr_reader :model
    def initialize(model:)
      @model = model
    end

    def persist
      generate_id if model.id.blank?
      solr_connection.add solr_document, params: { softCommit: true }
      model
    end

    def solr_document
      ::Valkyrie::Persistence::Solr::ResourceFactory.from_model(model).to_h
    end

    def solr_connection
      Blacklight.default_index.connection
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
