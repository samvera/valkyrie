# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class ResourceFactory
    attr_reader :resource_indexer
    def initialize(resource_indexer:)
      @resource_indexer = resource_indexer
    end

    def to_model(solr_document)
      ModelBuilder.new(solr_document).model
    end

    def from_model(model)
      ::SolrDocument.new(::Valkyrie::Persistence::Solr::Mapper.find(model).to_h.merge(internal_model_ssim: model.internal_model).merge(indexer_solr(model)))
    end

    def indexer_solr(model)
      resource_indexer.new(resource: model).to_solr
    end

    class ModelBuilder
      attr_reader :solr_document
      def initialize(solr_document)
        @solr_document = solr_document
      end

      def model
        model_klass.new(attributes.symbolize_keys)
      end

      def model_klass
        internal_model.constantize
      end

      def attributes
        attribute_hash.merge("id" => id, internal_model: internal_model)
      end

      def internal_model
        solr_document["internal_model_ssim"].first
      end

      def id
        solr_document["id"].gsub(/^id-/, '')
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

      class Property
        attr_reader :key, :value, :document
        def initialize(key, value, document)
          @key = key
          @value = value
          @document = document
        end
      end

      def build_literals(hsh)
        hsh.each_with_object({}) do |(key, value), output|
          next if key.end_with?("_lang")
          output[key] = SolrValue.for(Property.new(key, value, hsh)).result
        end
      end

      class SolrValue < ValueMapper
      end
      class LanguagePropertyValue < ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.document["#{value.key}_lang"]
        end

        def result
          value.value.zip(languages).map do |literal, language|
            if language == "eng"
              literal
            else
              RDF::Literal.new(literal, language: language)
            end
          end
        end

        def languages
          value.document["#{value.key}_lang"]
        end
      end
      class PropertyValue < ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.is_a?(Property)
        end

        def result
          calling_mapper.for(value.value).result
        end
      end
      class EnumerableValue < ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.respond_to?(:each)
        end

        def result
          value.map do |element|
            calling_mapper.for(element).result
          end
        end
      end

      class IDValue < ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("id-")
        end

        def result
          Valkyrie::ID.new(value.gsub(/^id-/, ''))
        end
      end

      class URIValue < ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("uri-")
        end

        def result
          ::RDF::URI.new(value.gsub(/^uri-/, ''))
        end
      end

      class IntegerValue < ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("integer-")
        end

        def result
          value.gsub(/^integer-/, '').to_i
        end
      end
    end
  end
end
