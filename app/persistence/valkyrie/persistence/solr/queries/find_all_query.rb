# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindAllQuery
    attr_reader :connection, :resource_factory
    def initialize(connection:, resource_factory:)
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      enum_for(:each)
    end

    def each
      docs = DefaultPaginator.new
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, "select", params: { q: "*:*" })["response"]["docs"]
        docs.each do |doc|
          yield resource_factory.to_model(doc)
        end
      end
    end
  end
end
