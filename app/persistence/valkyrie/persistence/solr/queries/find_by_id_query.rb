# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindByIdQuery
    attr_reader :id
    def initialize(id)
      @id = id
    end

    def run
      Valkyrie::Persistence::Solr::ResourceFactory.to_model(model)
    end

    def model
      solr_connection.get("select", params: { q: "id:#{id}", fl: "*", rows: 1 })["response"]["docs"].first
    end

    def solr_connection
      Blacklight.default_index.connection
    end
  end
end
