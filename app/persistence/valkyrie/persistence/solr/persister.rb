# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Persister
    class << self
      def save(model)
        self.new(model: model).persist
      end
    end

    attr_reader :model
    def initialize(model:)
      @model = model
    end

    def persist
      solr_connection.add solr_document, params: { softCommit: true }
    end

    def solr_document
      ::Valkyrie::Persistence::Solr::ResourceFactory.from_model(model).to_h
    end

    def solr_connection
      Blacklight.default_index.connection
    end
  end
end
