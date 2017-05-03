# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  class FindParentQuery
    attr_reader :model, :connection, :resource_factory
    def initialize(model:, connection:, resource_factory:)
      @model = model
      @connection = connection
      @resource_factory = resource_factory
    end

    def run
      enum_for(:each)
    end

    def each
      docs = DefaultPaginator.new
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
        docs.each do |doc|
          yield resource_factory.to_model(doc)
        end
      end
    end

    def query
      "member_ids_ssim:id-#{model.id}"
    end
  end
end
