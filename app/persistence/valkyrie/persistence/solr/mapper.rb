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

    def to_h
      {
        "id": id
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
          SolrMapperValue.for(Property.new(property, object.__send__(property))).result.apply_to(hsh)
        end
      end

      def properties
        object.attributes.keys - [:id]
      end

      class SolrMapperValue < ValueMapper
      end

      class EnumerableValue < ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.respond_to?(:each)
        end

        def result
          CompositeSolrRow.new(
            value.value.map do |val|
              calling_mapper.for(Property.new(value.key, val, value.value)).result
            end
          )
        end
      end

      class NilPropertyValue < ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.nil?
        end

        def result
          SolrRow.new(key: value.key, fields: [], values: nil)
        end
      end

      class IDPropertyValue < ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::Valkyrie::ID)
        end

        def result
          calling_mapper.for(Property.new(value.key, "id-#{value.value.id}")).result
        end
      end

      class URIPropertyValue < ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::RDF::URI)
        end

        def result
          calling_mapper.for(Property.new(value.key, "uri-#{value.value}")).result
        end
      end

      class IntegerPropertyValue < ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Integer)
        end

        def result
          calling_mapper.for(Property.new(value.key, "integer-#{value.value}")).result
        end
      end

      class SharedStringPropertyValue < ValueMapper
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

      class StringPropertyValue < ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(String)
        end

        def result
          SolrRow.new(key: value.key, fields: [:ssim, :tesim], values: value.value)
        end
      end

      class LiteralPropertyValue < ValueMapper
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
