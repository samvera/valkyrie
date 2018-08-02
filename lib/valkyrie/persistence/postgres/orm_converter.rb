# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  # Responsible for converting a
  # {Valkyrie::Persistence::Postgres::ORM::Resource} to a {Valkyrie::Resource}
  class ORMConverter
    attr_reader :orm_object, :resource_factory
    def initialize(orm_object, resource_factory:)
      @orm_object = orm_object
      @resource_factory = resource_factory
    end

    # Create a new instance of the class described in attributes[:internal_resource]
    # and send it all the attributes that @orm_object has
    def convert!
      @resource ||= resource
    end

    private

      def resource
        resource_klass.new(
          attributes.merge(
            new_record: false,
            Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => lock_token
          )
        )
      end

      def lock_token
        return lock_token_warning unless orm_object.class.column_names.include?("lock_version")
        @lock_token ||=
          Valkyrie::Persistence::OptimisticLockToken.new(
            adapter_id: resource_factory.adapter_id,
            token: orm_object.lock_version
          )
      end

      def lock_token_warning
        return nil unless resource_klass.optimistic_locking_enabled?
        warn "[MIGRATION REQUIRED] You have loaded a resource from the Postgres adapter with " \
             "optimistic locking enabled, but the necessary migrations have not been run. \n" \
             "Please run `bin/rails valkyrie_engine:install:migrations && bin/rails db:migrate` " \
             "to enable this feature for Postgres."
        nil
      end

      def resource_klass
        internal_resource.constantize
      end

      def internal_resource
        attributes[:internal_resource]
      end

      # @return [Hash] Valkyrie-style hash of attributes.
      def attributes
        @attributes ||= orm_object.attributes.merge(rdf_metadata).symbolize_keys
      end

      def rdf_metadata
        @rdf_metadata ||= RDFMetadata.new(orm_object.metadata).result
      end

      # Responsible for converting `metadata` JSON-B field in
      # {Valkyrie::Persistence::Postgres::ORM::Resource} into an acceptable hash
      # for {Valkyrie::Resource}
      class RDFMetadata
        attr_reader :metadata
        def initialize(metadata)
          # nil hash values are handled by the default state in dry-types
          # anyways, so don't bother processing them here.
          @metadata = metadata.compact
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
            RDF::Literal.new(value["@value"],
                             language: value["@language"],
                             datatype: value["@type"])
          end
        end

        # Converts stored IDs into {Valkyrie::ID}s
        class IDValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value["id"] && !value["internal_resource"]
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

        # Converts nested records into {Valkyrie::Resource}s
        class NestedRecord < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.is_a?(Hash) && value.keys.length > 1
          end

          def result
            RDFMetadata.new(value).result.symbolize_keys
          end
        end

        # Handles iterating over arrays of values and converting each value.
        class EnumeratorValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            value.respond_to?(:each)
          end

          def result
            # Cast single-valued arrays to the first value, let Types::Set and
            # Types::Array handle converting it back.
            if value.length == 1
              calling_mapper.for(value.first).result
            else
              value.map do |value|
                calling_mapper.for(value).result
              end
            end
          end
        end

        # Converts Date strings to `DateTime`
        class DateValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)
          def self.handles?(value)
            return false unless value.is_a?(String)
            return false unless value[4] == "-"
            year = value.to_s[0..3]
            return false unless year.length == 4 && year.to_i.to_s == year
            DateTime.iso8601(value)
          rescue
            false
          end

          def result
            DateTime.iso8601(value).utc
          end
        end
      end
  end
end
