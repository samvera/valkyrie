# frozen_string_literal: true
module Penguin::Persistence::Postgres
  module ORM
    class Resource < ActiveRecord::Base
      store_accessor :metadata, *(::Book.attribute_set.map(&:name) - [:id])

      def all_attributes
        attributes.merge(rdf_metadata)
      end

      def rdf_metadata
        RDFMetadata.new(metadata).result
      end

      class RDFMetadata
        attr_reader :metadata
        def initialize(metadata)
          @metadata = metadata
        end

        def result
          Hash[
            metadata.map do |key, value|
              [key, Value.for(value).result]
            end
          ]
        end

        class Value
          class << self
            def for(value)
              if value.is_a?(Hash) && value["@value"]
                HashValue.new(value)
              elsif value.respond_to?(:each)
                EnumeratorValue.new(value)
              else
                Value.new(value)
              end
            end
          end

          attr_reader :value
          def initialize(value)
            @value = value
          end

          def result
            value
          end
        end

        class HashValue < Value
          def result
            RDF::Literal.new(value["@value"], language: value["@language"])
          end
        end

        class EnumeratorValue < Value
          def result
            value.map do |value|
              Value.for(value).result
            end
          end
        end
      end
    end
  end
end
