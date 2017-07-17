# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  module ORM
    class Resource < ActiveRecord::Base
      after_save :assign_secondary_identifier, if: ->(obj){ obj.secondary_identifier.blank? }

      # @return [Hash] Valkyrie-style hash of attributes.
      def all_attributes
        attributes.merge(rdf_metadata).symbolize_keys.merge({id: secondary_identifier})
      end

      def rdf_metadata
        RDFMetadata.new(metadata).result
      end

      def assign_secondary_identifier
        update_attribute(:secondary_identifier, id)
      end

      class RDFMetadata
        attr_reader :metadata
        def initialize(metadata)
          @metadata = metadata
        end

        def result
          Hash[
            metadata.map do |key, value|
              [key, PostgresValue.for(value).result]
            end
          ]
        end

        class PostgresValue < ::Valkyrie::ValueMapper
        end
        # Converts {RDF::Literal} typed-literals from JSON-LD stored into an
        #   {RDF::Literal}
        class HashValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["@value"]
          end

          def result
            RDF::Literal.new(value["@value"], language: value["@language"])
          end
        end

        # Converts stored IDs into {Valkyrie::ID}s
        class IDValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["id"]
          end

          def result
            Valkyrie::ID.new(value["id"])
          end
        end

        # Converts stored URIs into {RDF::URI}s
        class URIValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["@id"]
          end

          def result
            ::RDF::URI.new(value["@id"])
          end
        end

        # Converts nested records into {Valkyrie::Model}s
        class NestedRecord < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value.keys.length > 1
          end

          def result
            RDFMetadata.new(value).result.symbolize_keys
          end
        end

        class DateValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            DateTime.parse(value).utc
          rescue
            false
          end

          def result
            DateTime.parse(value).utc
          end
        end

        class EnumeratorValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.respond_to?(:each)
          end

          def result
            value.map do |value|
              calling_mapper.for(value).result
            end
          end
        end
      end
    end
  end
end
