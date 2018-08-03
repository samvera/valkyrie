# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  # Default schema for Fedora MetadataAdapter. It's used to generate a mapping
  # of {Valkyrie::Resource} attributes to predicates. This implementation will
  # make up a URI if one doesn't exist in a passed in schema.
  #
  # @example Passing in a mapping
  #   schema = Valkyrie::Persistence::Fedora::PermissiveSchema.new(member_ids:
  #     RDF::URI("http://mypredicates.com/member_ids"))
  #   schema.predicate_for(resource: Resource.new, property: :member_ids) # => RDF::URI<"http://mypredicates.com/member_ids">
  #   schema.predicate_for(resource: Resource.new, property: :unknown) # => RDF::URI<"http://example.com/predicate/unknown">
  class PermissiveSchema
    URI_PREFIX = 'http://example.com/predicate/'

    # @return [RDF::URI]
    def self.valkyrie_id
      uri_for('valkyrie_id')
    end

    # @return [RDF::URI]
    def self.id
      uri_for(:id)
    end

    # @deprecated Please use {.uri_for} instead
    def self.alternate_ids
      warn "[DEPRECATION] `alternate_ids` is deprecated and will be removed in the next major release. " \
           "It was never used internally - please use `uri_for(:alternate_ids)` " \
           "Called from #{Gem.location_of_caller.join(':')}"
      uri_for(:alternate_ids)
    end

    # @return [RDF::URI]
    def self.member_ids
      uri_for(:member_ids)
    end

    # @deprecated Please use {.uri_for} instead
    def self.references
      warn "[DEPRECATION] `references` is deprecated and will be removed in the next major release. " \
           "It was never used internally - please use `uri_for(:references)` " \
           "Called from #{Gem.location_of_caller.join(':')}"
      uri_for(:references)
    end

    # @return [RDF::URI]
    def self.valkyrie_bool
      uri_for(:valkyrie_bool)
    end

    # @return [RDF::URI]
    def self.valkyrie_datetime
      uri_for(:valkyrie_datetime)
    end

    # @return [RDF::URI]
    def self.valkyrie_int
      uri_for(:valkyrie_int)
    end

    # @return [RDF::URI]
    def self.valkyrie_time
      uri_for(:valkyrie_time)
    end

    # @return [RDF::URI]
    def self.optimistic_lock_token
      uri_for(:optimistic_lock_token)
    end

    # Cast the property to a URI in the namespace
    # @param property [Symbol]
    # @return [RDF::URI]
    def self.uri_for(property)
      RDF::URI("#{URI_PREFIX}#{property}")
    end

    attr_reader :schema
    def initialize(schema = {})
      @schema = schema
    end

    def predicate_for(resource:, property:)
      schema.fetch(property) { self.class.uri_for(property) }
    end

    # Find the property in the schema. If it's not there check to see
    # if this prediate is in the URI_PREFIX namespace, return the suffix as the property
    # @example:
    #   property_for(resource: nil, predicate: "http://example.com/predicate/internal_resource")
    #   #=> 'internal_resource'
    def property_for(resource:, predicate:)
      (schema.find { |_k, v| v == RDF::URI(predicate.to_s) } || []).first || predicate.to_s.gsub(URI_PREFIX, '')
    end
  end
end
