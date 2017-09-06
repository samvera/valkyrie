# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindAllQuery
    attr_reader :connection, :resource_factory, :model
    def initialize(connection:, resource_factory:, model: nil)
      @connection = connection
      @resource_factory = resource_factory
      @model = model
    end

    def run
      enum_for(:each)
    end

    def each
      docs = DefaultPaginator.new
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
        docs.each do |doc|
          yield resource_factory.to_resource(object: doc)
        end
      end
    end

    def query
      if !model
        "*:*"
      else
        "internal_resource_ssim:#{model}"
      end
    end
  end
end
