# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  # Responsible for converting a {Valkyrie::Resource} into hashes for indexing
  # into Solr.
  class ModelConverter
    attr_reader :resource, :resource_factory
    delegate :resource_indexer, to: :resource_factory
    def initialize(resource, resource_factory:)
      @resource = resource
      @resource_factory = resource_factory
    end

    def convert!
      to_h.merge(Valkyrie::Persistence::Solr::Queries::MODEL.to_sym => [resource.internal_resource])
          .merge(indexer_solr(resource))
    end

    def indexer_solr(resource)
      resource_indexer.new(resource: resource).to_solr
    end

    # @return [String] The solr document ID
    def id
      resource.id.to_s
    end

    # @return [String] ISO-8601 timestamp in UTC of the created_at for this solr
    #   document.
    def created_at
      if resource_attributes[:created_at]
        DateTime.parse(resource_attributes[:created_at].to_s).utc.iso8601
      else
        Time.current.utc.iso8601
      end
    end

    # @return [Hash] Solr document to index.
    def to_h
      {
        "id": id,
        "join_id_ssi": "id-#{id}",
        "created_at_dtsi": created_at
      }.merge(add_single_values(attribute_hash)).merge(lock_hash)
    end

    private

      def add_single_values(attribute_hash)
        attribute_hash.select do |k, v|
          field = k.to_s.split("_").last
          property = k.to_s.gsub("_#{field}", "")
          next true if multivalued?(field)
          next false if property == "internal_resource"
          next false if v.length > 1
          true
        end
      end

      def multivalued?(field)
        field.end_with?('m', 'mv')
      end

      def lock_hash
        return {} unless resource.optimistic_locking_enabled? && lock_token.present?
        { _version_: lock_token }
      end

      def lock_token
        @lock_token ||= resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK).first
      end

      def attribute_hash
        properties.each_with_object({}) do |property, hsh|
          attr = resource_attributes[property]
          mapper_val = SolrMapperValue.for(Property.new(property, attr)).result
          unless mapper_val.respond_to?(:apply_to)
            raise "Unable to cast #{resource_attributes[:internal_resource]}#" \
                  "#{property} which has been set to an instance of '#{attr.class}'"
          end
          mapper_val.apply_to(hsh)
        end
      end

      def properties
        resource_attributes.keys - [:id, :created_at, :updated_at, :new_record]
      end

      def resource_attributes
        @resource_attributes ||= resource.attributes
      end

      ##
      # A container resource for holding a `key`, `value, and `scope` of a value
      # in a resource together for casting.
      class Property
        attr_reader :key, :value, :scope
        # @param key [Symbol] Property identifier.
        # @param value [Object] Value or list of values which are underneath the
        #   key.
        # @param scope [Object] The resource or point where the key and values
        #   came from.
        def initialize(key, value, scope = [])
          @key = key
          @value = value
          @scope = scope
        end
      end

      ##
      # Represents a key/value combination in the solr document, used for isolating logic around
      # how to apply a value to a hash.
      class SolrRow
        attr_reader :key, :fields, :values
        # @param key [Symbol] Solr key.
        # @param fields [Array<Symbol>] Field suffixes to index into.
        # @param values [Array] Values to index into the given fields.
        def initialize(key:, fields:, values:)
          @key = key
          @fields = Array.wrap(fields)
          @values = Array.wrap(values)
        end

        # @param hsh [Hash] The solr hash to apply to.
        # @return [Hash] The updated solr hash.
        def apply_to(hsh)
          return hsh if values.blank?
          fields.each do |field|
            hsh["#{key}_#{field}".to_sym] ||= []
            hsh["#{key}_#{field}".to_sym] += values
          end
          hsh
        end
      end

      ##
      # Wraps up multiple SolrRows to apply them all at once, while looking like
      # just one.
      class CompositeSolrRow
        attr_reader :solr_rows
        def initialize(solr_rows)
          @solr_rows = solr_rows
        end

        # @see Valkyrie::Persistence::Solr::Mapper::SolrRow#apply_to
        def apply_to(hsh)
          solr_rows.each do |solr_row|
            solr_row.apply_to(hsh)
          end
          hsh
        end
      end

      # Container for casting mappers.
      class SolrMapperValue < ::Valkyrie::ValueMapper
      end

      # Casts {Boolean} values into a recognizable string in Solr.
      class BooleanPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && ([true, false].include? value.value)
        end

        def result
          calling_mapper.for(Property.new(value.key, "boolean-#{value.value}")).result
        end
      end

      # Casts nested resources into a JSON string in solr.
      class NestedObjectValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.value.is_a?(Hash)
        end

        def result
          SolrRow.new(key: value.key, fields: ["tsim"], values: "serialized-#{value.value.to_json}")
        end
      end

      # Casts enumerable values one by one.
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

      # Skips nil values.
      class NilPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.nil?
        end

        def result
          SolrRow.new(key: value.key, fields: [], values: nil)
        end
      end

      # Casts {Valkyrie::ID} values into a recognizable string in solr.
      class IDPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::Valkyrie::ID)
        end

        def result
          calling_mapper.for(Property.new(value.key, "id-#{value.value.id}")).result
        end
      end

      # Casts {RDF::URI} values into a recognizable string in solr.
      class URIPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::RDF::URI)
        end

        def result
          calling_mapper.for(Property.new(value.key, "uri-#{value.value}")).result
        end
      end

      # Casts {Integer} values into a recognizable string in Solr.
      class IntegerPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(Integer)
        end

        def result
          calling_mapper.for(Property.new(value.key, "integer-#{value.value}")).result
        end
      end

      # Casts {DateTime} values into a recognizable string in Solr.
      class DateTimePropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && (value.value.is_a?(Time) || value.value.is_a?(DateTime))
        end

        def result
          calling_mapper.for(Property.new(value.key, "datetime-#{JSON.parse(to_datetime(value.value).to_json)}")).result
        end

        private

          def to_datetime(value)
            return value.utc if value.is_a?(DateTime)
            return value.to_datetime.utc if value.respond_to?(:to_datetime)
          end
      end

      # Handles casting language-tagged strings when there are both
      # language-tagged and non-language-tagged strings in Solr. Assumes English
      # for non-language-tagged strings.
      class SharedStringPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(String) && value.scope.find { |x| x.is_a?(::RDF::Literal) }.present?
        end

        def result
          CompositeSolrRow.new(
            [
              calling_mapper.for(Property.new(value.key, value.value)).result,
              calling_mapper.for(Property.new("#{value.key}_lang", "eng")).result,
              calling_mapper.for(Property.new("#{value.key}_type", "http://www.w3.org/1999/02/22-rdf-syntax-ns#langString")).result
            ]
          )
        end
      end

      # Handles casting strings.
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
            [:tsim, :ssim, :tesim, :tsi, :ssi, :tesi]
          end
        end
      end

      # Handles casting language-typed {RDF::Literal}s
      class LiteralPropertyValue < ::Valkyrie::ValueMapper
        SolrMapperValue.register(self)
        def self.handles?(value)
          value.is_a?(Property) && value.value.is_a?(::RDF::Literal)
        end

        def result
          key = value.key
          val = value.value
          CompositeSolrRow.new(
            [
              calling_mapper.for(Property.new(key, val.to_s)).result,
              calling_mapper.for(Property.new("#{key}_lang", val.language.to_s)).result,
              calling_mapper.for(Property.new("#{key}_type", val.datatype.to_s)).result
            ]
          )
        end
      end
  end
end
