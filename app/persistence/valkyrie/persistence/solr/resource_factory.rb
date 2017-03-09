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
        build_literals(strip_ssim(solr_document.select do |k, _v|
          k.end_with?("ssim")
        end))
      end

      def strip_ssim(hsh)
        Hash[
          hsh.map do |k, v|
            [k.gsub("_ssim", ""), v]
          end
        ]
      end

      def build_literals(hsh)
        hsh.each_with_object({}) do |(key, value), output|
          next if key.end_with?("_lang")
          output[key] = if hsh["#{key}_lang"]
                          literal_values(key, hsh)
                        else
                          value
                        end
        end
      end

      def literal_values(key, hsh)
        Array.wrap(hsh[key]).each_with_index.map do |value, index|
          language = Array.wrap(hsh["#{key}_lang"])[index]
          if language == "eng"
            value
          else
            RDF::Literal.new(value, language: language)
          end
        end
      end
    end
  end
end
