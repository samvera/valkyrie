# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
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
              [key, PostgresValue.for(value).result]
            end
          ]
        end

        class PostgresValue < ValueMapper
        end
        class HashValue < ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["@value"]
          end

          def result
            RDF::Literal.new(value["@value"], language: value["@language"])
          end
        end

        class IDValue < ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["id"]
          end

          def result
            Valkyrie::ID.new(value["id"])
          end
        end

        class DateValue < ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            DateTime.parse(value).in_time_zone
          rescue
            false
          end

          def result
            DateTime.parse(value).in_time_zone
          end
        end

        class EnumeratorValue < ValueMapper
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
