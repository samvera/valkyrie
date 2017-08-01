# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class ResourceFactory
    require 'valkyrie/persistence/solr/mapper'
    attr_reader :resource_indexer
    def initialize(resource_indexer:)
      @resource_indexer = resource_indexer
    end

    # @param solr_document [Hash] The solr document in a hash to convert to a
    #   resource.
    # @return [Valkyrie::Resource]
    def to_resource(solr_document)
      ModelBuilder.new(solr_document).resource
    end

    # @param resource [Valkyrie::Resource] The resource to convert to a solr hash.
    # @return [Hash] The solr document represented as a hash.
    def from_resource(resource)
      Hash[::Valkyrie::Persistence::Solr::Mapper.find(resource).to_h.merge(internal_resource_ssim: [resource.internal_resource]).merge(indexer_solr(resource))]
    end

    def indexer_solr(resource)
      resource_indexer.new(resource: resource).to_solr
    end

    ##
    # Converts a solr hash to a {Valkyrie::Resource}
    class ModelBuilder
      attr_reader :solr_document
      def initialize(solr_document)
        @solr_document = solr_document
      end

      def resource
        resource_klass.new(attributes.symbolize_keys)
      end

      def resource_klass
        internal_resource.constantize
      end

      def internal_resource
        solr_document["internal_resource_ssim"].first
      end

      def attributes
        attribute_hash.merge("id" => id, internal_resource: internal_resource, created_at: created_at, updated_at: updated_at)
      end

      def created_at
        DateTime.parse(solr_document["created_at_dtsi"].to_s).utc
      end

      def updated_at
        DateTime.parse(solr_document["timestamp"] || solr_document["created_at_dtsi"].to_s).utc
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

      # Converts a nested resource in solr into a {Valkyrie::Resource}
      class NestedResourceValue < ::Valkyrie::ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          value.to_s.start_with?("serialized-")
        end

        def result
          NestedResourceConverter.for(JSON.parse(json, symbolize_names: true)).result
        end

        def json
          value.gsub(/^serialized-/, '')
        end
      end

      class NestedResourceConverter < ::Valkyrie::ValueMapper
      end

      class NestedEnumerable < ::Valkyrie::ValueMapper
        NestedResourceConverter.register(self)
        def self.handles?(value)
          value.is_a?(Array)
        end

        def result
          value.map do |v|
            calling_mapper.for(v).result
          end
        end
      end

      class NestedResourceID < ::Valkyrie::ValueMapper
        NestedResourceConverter.register(self)
        def self.handles?(value)
          value.is_a?(Hash) && value[:id] && !value[:internal_resource]
        end

        def result
          Valkyrie::ID.new(value[:id])
        end
      end

      class NestedResourceHash < ::Valkyrie::ValueMapper
        NestedResourceConverter.register(self)
        def self.handles?(value)
          value.is_a?(Hash)
        end

        def result
          Hash[
            value.map do |k, v|
              [k, calling_mapper.for(v).result]
            end
          ]
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

      # Converts a datetime in Solr into a {DateTime}
      class DateTimeValue < ::Valkyrie::ValueMapper
        SolrValue.register(self)
        def self.handles?(value)
          DateTime.iso8601(value.gsub(/^datetime-/, '')).utc
        rescue
          false
        end

        def result
          DateTime.parse(value.gsub(/^datetime-/, '')).utc
        end
      end
    end
  end
end
