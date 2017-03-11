# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindByIdQuery
    attr_reader :id, :connection
    def initialize(id, connection:)
      @id = id
      @connection = connection
    end

    def run
      Valkyrie::Persistence::Solr::ResourceFactory.to_model(model)
    end

    def model
      connection.get("select", params: { q: "id:#{id}", fl: "*", rows: 1 })["response"]["docs"].first
    end
  end
end
