# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora::Queries
  class FindReferencesQuery
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
          yield resource_factory.to_model(ActiveFedora::Base.find(doc["id"]))
        end
      end
    end

    private

      def query
        "{!join from=#{property}_ssim to=uri_ssi}id:#{id}"
      end

      def connection
        ActiveFedora.solr.conn
      end

      def resource_factory
        ::Valkyrie::Persistence::ActiveFedora::ResourceFactory
      end
  end
end
