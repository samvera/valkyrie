# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class ResourceFactory
    require 'valkyrie/persistence/solr/mapper'
    attr_reader :resource_indexer
    def initialize(resource_indexer:)
      @resource_indexer = resource_indexer
    end

    # @param solr_document [Hash] The solr document in a hash to convert to a
    #   model.
    # @return [Valkyrie::Model]
    def to_model(solr_document)
      ModelBuilder.new(solr_document).model
    end

    # @param model [Valkyrie::Model] The model to convert to a solr hash.
    # @return [Hash] The solr document represented as a hash.
    def from_model(model)
      Hash[::Valkyrie::Persistence::Solr::Mapper.find(model).to_h.merge(internal_model_ssim: [model.internal_model]).merge(indexer_solr(model))]
    end

    def indexer_solr(model)
      resource_indexer.new(resource: model).to_solr
    end

    ##
    # Converts a solr hash to a {Valkyrie::Model}
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

      def internal_model
        solr_document["internal_model_ssim"].first
      end

      def attributes
        attribute_hash.merge("id" => id, internal_model: internal_model, created_at: created_at, updated_at: updated_at)
      end

      def created_at
        DateTime.parse(solr_document["created_at_dtsi"].to_s).in_time_zone
      end

      def updated_at
        DateTime.parse(solr_document["timestamp"] || solr_document["created_at_dtsi"].to_s).in_time_zone
      end

      def id
        solr_document["id"].gsub(/^id-/, '')
      end

      def attribute_hash
        build_literals(strip_tsim(solr_document.select do |k, _v|
          k.end_with?("tsim")
        end))
      end

      def strip_tsim(hsh)
        Hash[
          hsh.map do |k, v|
            [k.gsub("_tsim", ""), v]
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

      class SolrValue < ::Valkyrie::ValueMapper
      end

      # Converts a stored language typed literal from two fields into one
      #   {RDF::Literal}
      class LanguagePropertyValue < ::Valkyrie::ValueMapper
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
      class PropertyValue < ::Valkyrie::ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.is_a?(Property)
        end

        def result
          calling_mapper.for(value.value).result
        end
      end
      class EnumerableValue < ::Valkyrie::ValueMapper
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

      # Converts a stored ID value in solr into a {Valkyrie::ID}
      class IDValue < ::Valkyrie::ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("id-")
        end

        def result
          Valkyrie::ID.new(value.gsub(/^id-/, ''))
        end
      end

      # Converts a stored URI value in solr into a {RDF::URI}
      class URIValue < ::Valkyrie::ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("uri-")
        end

        def result
          ::RDF::URI.new(value.gsub(/^uri-/, ''))
        end
      end

      # Converts a nested resource in solr into a {Valkyrie::Model}
      class NestedResourceValue < ::Valkyrie::ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("serialized-")
        end

        def result
          JSON.parse(json, symbolize_names: true)
        end

        def json
          value.gsub(/^serialized-/, '')
        end
      end

      # Converts an integer in solr into an {Integer}
      class IntegerValue < ::Valkyrie::ValueMapper
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
