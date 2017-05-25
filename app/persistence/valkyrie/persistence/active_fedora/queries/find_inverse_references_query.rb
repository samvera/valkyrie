# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora::Queries
  class FindInverseReferencesQuery
    attr_reader :obj, :property
    delegate :id, to: :obj
    def initialize(obj, property)
      @obj = obj
      @property = property
    end

    def run
      enum_for(:each)
    end

    def each
      docs = DefaultPaginator.new
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query })["response"]["docs"]
        docs.each do |doc|
          yield resource_factory.to_model(ActiveFedora::SolrHit.for(doc))
        end
      end
    end

    def query
      "#{property}_ssim:\"#{RSolr.solr_escape(resource_class.id_to_uri(id.to_s))}\""
    end

    def connection
      ActiveFedora.solr.conn
    end

    def resource_class
      ::Valkyrie::Persistence::ActiveFedora::ORM::Resource
    end

    def resource_factory
      ::Valkyrie::Persistence::ActiveFedora::ResourceFactory
    end
  end
end
