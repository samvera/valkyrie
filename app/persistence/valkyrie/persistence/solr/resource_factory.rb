# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class ResourceFactory
    class << self

      def to_model(solr_document)
        ModelBuilder.new(solr_document).model
      end

      def from_model(model)
        ::SolrDocument.new(::Valkyrie::Persistence::Solr::Mapper.find(model).to_h.merge(inner_model_ssim: model.resource_class.to_s))
      end
    end

    class ModelBuilder
      attr_reader :solr_document
      def initialize(solr_document)
        @solr_document = solr_document
      end

      def model
        model_klass.new(attributes)
      end

      def model_klass
        solr_document["inner_model_ssim"].first.constantize
      end

      def attributes
        attribute_hash.merge("id" => id)
      end

      def id
        solr_document["id"]
      end

      def attribute_hash
        strip_ssim(solr_document.select do |k, _v|
          k.end_with?("ssim")
        end)
      end

      def strip_ssim(hsh)
        Hash[
          hsh.map do |k, v|
            [k.gsub("_ssim", ""), v]
          end
        ]
      end
    end
  end
end
