# frozen_string_literal: true
module Valkyrie::Persistence::Solr::Queries
  # Responsible for efficently returning all {Valkyrie::Resource}s which are referenced in
  # a given {Valkyrie::Resource}'s property.
  class FindReferencesQuery
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
        params = { q: query, defType: 'lucene' }
        result = connection.paginate(docs.next_page, docs.per_page, 'select', params: params)
        docs = result.fetch('response').fetch('docs')
        docs.each do |doc|
          yield resource_factory.to_resource(object: doc)
        end
      end
    end

    def query
      "{!join from=#{property}_ssim to=join_id_ssi}id:#{id}"
    end

    def id
      resource.id.to_s
    end
  end
end
