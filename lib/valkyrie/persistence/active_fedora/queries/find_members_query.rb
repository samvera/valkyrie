# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora::Queries
  class FindMembersQuery
    attr_reader :obj
    delegate :id, to: :obj
    def initialize(obj)
      @obj = obj
    end

    def run
      return [] unless obj.id.present?
      ordered_docs.map do |solr_document|
        resource_factory.to_resource(solr_document)
      end
    end

    private

      def ordered_docs
        @ordered_docs ||= begin
                            ActiveFedora::SolrService.query("{!join from=ordered_targets_ssim to=id}proxy_in_ssi:#{id}", rows: 100_000).sort_by { |x| ordered_ids.index(x["id"]) }
                          end
      end

      def ordered_ids
        @ordered_ids ||= begin
                           ActiveFedora::SolrService.query("proxy_in_ssi:#{id}",
                                                           rows: 10_000,
                                                           fl: "ordered_targets_ssim")
                                                    .flat_map { |x| x.fetch("ordered_targets_ssim", []) }
                         end
      end

      def resource_factory
        ::Valkyrie::Persistence::ActiveFedora::ResourceFactory
      end
  end
end
