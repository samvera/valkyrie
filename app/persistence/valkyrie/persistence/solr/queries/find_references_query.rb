# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindReferencesQuery
    attr_reader :model, :property, :connection, :resource_factory
    def initialize(model:, property:, connection:, resource_factory:)
      @model = model
      @property = property
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      enum_for(:each)
    end

    def each
      unordered_result.each do |member|
        yield member
      end
    end

    def unordered_result
      docs.map do |doc|
        resource_factory.to_model(doc)
      end
    end

    def docs
      connection.get("select", params: { q: query, rows: 1_000_000_000 })["response"]["docs"]
    end

    def query
      "{!join from=#{property}_ssim to=id}id:#{id}"
    end

    def id
      "id-#{model.id}"
    end
  end
end
