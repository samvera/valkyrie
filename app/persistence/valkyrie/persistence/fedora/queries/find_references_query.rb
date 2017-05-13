# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Queries
  class FindReferencesQuery
    attr_reader :obj, :property
    delegate :id, to: :obj
    def initialize(obj, property)
      @obj = obj
      @property = property
    end

    def run
      return [] unless obj.id.present?
      docs.map do |solr_document|
        resource_factory.to_model(solr_document)
      end
    end

    private

      def docs
        @docs ||= begin
                            ActiveFedora::SolrService.query("{!join from=#{property}_ssim to=uri_ssi}id:#{id}", rows: 100_000)
                          end
      end

      def resource_factory
        ::Valkyrie::Persistence::Fedora::ResourceFactory
      end
  end
end
