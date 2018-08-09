# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  # Responsible for converting a
  # {Valkyrie::Persistence::Postgres::ORM::Resource} to a {Valkyrie::Resource}
  class ORMConverter
    attr_reader :orm_object, :resource_factory

    # @param [ORM::Resource] orm_object
    # @param [ResourceFactory] resource_factory
    def initialize(orm_object, resource_factory:)
      @orm_object = orm_object
      @resource_factory = resource_factory
    end

    # Create a new instance of the class described in attributes[:internal_resource]
    # and send it all the attributes that @orm_object has
    # @return [Valkyrie::Resource]
    def convert!
      @resource ||= resource
    end

    private

      # Construct a new Valkyrie Resource using the attributes retrieved from the database
      # @return [Valkyrie::Resource]
      def resource
        resource_klass.new(
          attributes.merge(
            new_record: false,
            Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => lock_token
          )
        )
      end

      # Construct the optimistic lock token using the adapter and lock version for the Resource
      # @return [Valkyrie::Persistence::OptimisticLockToken]
      def lock_token
        return lock_token_warning unless orm_object.class.column_names.include?("lock_version")
        @lock_token ||=
          Valkyrie::Persistence::OptimisticLockToken.new(
            adapter_id: resource_factory.adapter_id,
            token: orm_object.lock_version
          )
      end

      # Issue a migration warning for previous releases of Valkyrie which did not support optimistic locking
      def lock_token_warning
        return nil unless resource_klass.optimistic_locking_enabled?
        warn "[MIGRATION REQUIRED] You have loaded a resource from the Postgres adapter with " \
             "optimistic locking enabled, but the necessary migrations have not been run. \n" \
             "Please run `bin/rails valkyrie_engine:install:migrations && bin/rails db:migrate` " \
             "to enable this feature for Postgres."
        nil
      end

      # Retrieve the Class use to construct the Valkyrie Resource
      # @return [Class]
      def resource_klass
        internal_resource.constantize
      end

      # Access the String for the Valkyrie Resource type within the attributes
      # @return [String]
      def internal_resource
        attributes[:internal_resource]
      end

      # @return [Hash] Valkyrie-style hash of attributes.
      def attributes
        @attributes ||= orm_object.attributes.merge(rdf_metadata).symbolize_keys
      end

      # Generate a Hash derived from Valkyrie Resource metadata encoded in the RDF
      # @return [Hash]
      def rdf_metadata
        @rdf_metadata ||= RDFMetadata.new(orm_object.metadata).result
      end

      # Responsible for converting `metadata` JSON-B field in
      # {Valkyrie::Persistence::Postgres::ORM::Resource} into an acceptable hash
      # for {Valkyrie::Resource}
      class RDFMetadata
        attr_reader :metadata

        # @param [Hash] metadata
        def initialize(metadata)
          # nil hash values are handled by the default state in dry-types
          # anyways, so don't bother processing them here.
          @metadata = metadata.compact
        end

        # Convert the database attribute values and map these to the existing keys in the Valkyrie Resource metadata
        # @return [Hash]
        def result
          Hash[
            metadata.map do |key, value|
              [key, PostgresValue.for(value).result]
            end
          ]
        end

        # Abstract base class for mapping PostgreSQL database field values to Valkyrie Resource attributes
        class PostgresValue < ::Valkyrie::ValueMapper
        end

        # Converts {RDF::Literal} typed-literals from JSON-LD stored into an
        #   {RDF::Literal}
        class HashValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)

          # Determines whether or not a value is a Hash containing the key "@value"
          # @param [Object] value
          # @return [Boolean]
          def self.handles?(value)
            value.is_a?(Hash) && value["@value"]
          end

          # Constructs a RDF::Literal object using the Object keyed to "@value"
          # in the value Hash, as well as the language keyed to "@language" and
          # datatype keyed to "@type"
          # @return [RDF::Literal]
          def result
            RDF::Literal.new(value["@value"],
                             language: value["@language"],
                             datatype: value["@type"])
          end
        end

        # Converts stored IDs into {Valkyrie::ID}s
        class IDValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)

          # Determines whether or not a value is a Hash containing the key "id" (excluding those storing the Valkyrie Resource type)
          # @param [Object] value
          # @return [Boolean]
          def self.handles?(value)
            value.is_a?(Hash) && value["id"] && !value["internal_resource"]
          end

          # Constructs a Valkyrie::ID object using the String keyed to "id" in the value
          # @return [Valkyrie::ID]
          def result
            Valkyrie::ID.new(value["id"])
          end
        end

        # Converts stored URIs into {RDF::URI}s
        class URIValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)

          # Determines whether or not a value is a Hash containing the key "@id"
          # @param [Object] value
          # @return [Boolean]
          def self.handles?(value)
            value.is_a?(Hash) && value["@id"]
          end

          # Constructs a RDF::URI object using the URI keyed to @id in the value
          # @return [RDF::URI]
          def result
            ::RDF::URI.new(value["@id"])
          end
        end

        # Converts nested records into {Valkyrie::Resource}s
        class NestedRecord < ::Valkyrie::ValueMapper
          PostgresValue.register(self)

          # Determines whether or not a value is a Hash containing multiple keys
          # @param [Object] value
          # @return [Boolean]
          def self.handles?(value)
            value.is_a?(Hash) && value.keys.length > 1
          end

          # Generates a Hash derived from the RDFMetadata for the value
          # @return [Hash]
          def result
            RDFMetadata.new(value).result.symbolize_keys
          end
        end

        # Handles iterating over arrays of values and converting each value.
        class EnumeratorValue < ::Valkyrie::ValueMapper
          PostgresValue.register(self)

          # Determines whether or not a value has enumerable behavior
          # @param [Object] value
          # @return [Boolean]
          def self.handles?(value)
            value.respond_to?(:each)
          end

          # Convert the elements in the enumerable value in Valkyrie attribute values
          # Casts single-valued arrays to the first value, letting Types::Set and
          # Types::Array handle converting it back.
          # @return [Array<Object>]
          def result
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

          # Determines whether or not a value is an ISO 8601 datestamp String
          # e. g. 1970-01-01
          # @param [Object] value
          # @return [Boolean]
          def self.handles?(value)
            return false unless value.is_a?(String)
            return false unless value[4] == "-"
            year = value.to_s[0..3]
            return false unless year.length == 4 && year.to_i.to_s == year
            DateTime.iso8601(value)
          rescue
            false
          end

          # Generates a Time object in the UTC from the datestamp string value
          # @return [Time]
          def result
            DateTime.iso8601(value).utc
          end
        end
      end
  end
end
