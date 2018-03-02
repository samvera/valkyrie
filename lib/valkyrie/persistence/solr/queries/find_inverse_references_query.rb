# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  # Responsible for efficiently returning all {Valkyrie::Resource}s which
  # reference a {Valkyrie::Resource} in a given property.
  class FindInverseReferencesQuery
    attr_reader :resource, :property, :connection, :resource_factory
    def initialize(resource:, property:, connection:, resource_factory:)
      @resource = resource
      @property = property
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
          yield resource_factory.to_resource(object: doc)
        end
      end
    end

    def query
      "#{property}_ssim:id-#{resource.id}"
    end
  end
end
