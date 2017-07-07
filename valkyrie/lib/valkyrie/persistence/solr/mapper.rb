# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Mapper
    ## Find a mapper for a given object
    def self.find(obj)
      new(obj)
    end

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def id
      "id-#{object.id}"
    end

    def created_at
      object.attributes[:created_at] || Time.current.utc.iso8601
    end

    def to_h
      {
        "id": id,
        "created_at_dtsi": created_at
      }.merge(attribute_hash)
    end

    private

      class Property
        attr_reader :key, :value, :scope
        def initialize(key, value, scope = [])
          @key = key
          @value = value
          @scope = scope
        end
      end

      class SolrRow
        attr_reader :key, :fields, :values
        def initialize(key:, fields:, values:)
          @key = key
          @fields = Array.wrap(fields)
          @values = Array.wrap(values)
        end

        def apply_to(hsh)
          return hsh if values.blank?
          fields.each do |field|
            hsh["#{key}_#{field}".to_sym] ||= []
            hsh["#{key}_#{field}".to_sym] += values
          end
          hsh
        end
      end

      class CompositeSolrRow
        attr_reader :solr_rows
        def initialize(solr_rows)
          @solr_rows = solr_rows
        end

        def apply_to(hsh)
          solr_rows.each do |solr_row|
            solr_row.apply_to(hsh)
          end
          hsh
        end
      end

      def attribute_hash
        properties.each_with_object({}) do |property, hsh|
          SolrMapperValue.for(Property.new(property, object.attributes[property])).result.apply_to(hsh)
        end
      end

      def properties
        object.attributes.keys - [:id, :created_at, :updated_at]
      end

      class SolrMapperValue < ::Valkyrie::ValueMapper
      end

      class NestedObjectValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.value.is_a?(Hash)
        end

        def result
          SolrRow.new(key: value.key, fields: ["tsim"], values: "serialized-#{value.value.to_json}")
        end
      end

      class EnumerableValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Array)
        end

        def result
          CompositeSolrRow.new(
            value.value.map do |val|
              calling_mapper.for(Property.new(value.key, val, value.value)).result
            end
          )
        end
      end

      class NilPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.nil?
        end

        def result
          SolrRow.new(key: value.key, fields: [], values: nil)
        end
      end

      class IDPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::Valkyrie::ID)
        end

        def result
          calling_mapper.for(Property.new(value.key, "id-#{value.value.id}")).result
        end
      end

      class URIPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::RDF::URI)
        end

        def result
          calling_mapper.for(Property.new(value.key, "uri-#{value.value}")).result
        end
      end

      class IntegerPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Integer)
        end

        def result
          calling_mapper.for(Property.new(value.key, "integer-#{value.value}")).result
        end
      end

      class SharedStringPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(String) && value.scope.find { |x| x.is_a?(::RDF::Literal) }.present?
        end

        def result
          CompositeSolrRow.new(
            [
              calling_mapper.for(Property.new(value.key, value.value)).result,
              calling_mapper.for(Property.new("#{value.key}_lang", "eng")).result
            ]
          )
        end
      end

      class StringPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(String)
        end

        def result
          SolrRow.new(key: value.key, fields: fields, values: value.value)
        end

        def fields
          if value.value.length > 1000
            [:tsim]
          else
            [:tsim, :ssim, :tesim]
          end
        end
      end

      class LiteralPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::RDF::Literal)
        end

        def result
          CompositeSolrRow.new(
            [
              calling_mapper.for(Property.new(value.key, value.value.to_s)).result,
              calling_mapper.for(Property.new("#{value.key}_lang", value.value.language.to_s)).result
            ]
          )
        end
      end
  end
end
