# frozen_string_literal: true
module Valkyrie
  # Namespace for Dry::Types types.
  #  Includes Dry::Types built-in types and defines custom Valkyrie types
  #
  # @example Use types in property definitions on a resource
  #   class Book < Valkyrie::Resource
  #     attribute :id, Valkyrie::Types::ID.optional
  #     attribute :title, Valkyrie::Types::Set.optional  # default type if none is specified
  #     attribute :member_ids, Valkyrie::Types::Array
  #   end
  #
  # @note Not all Dry::Types built-in types are supported in Valkyrie
  # @see https://github.com/samvera-labs/valkyrie/wiki/Supported-Data-Types List of types supported in Valkyrie
  module Types
    include Dry::Types.module

    # Valkyrie::ID
    ID = Dry::Types::Definition
         .new(Valkyrie::ID)
         .constructor do |input|
      if input.respond_to?(:each)
        # Solr::ORMConverter tries to pass an array of Valkyrie::IDs
        Valkyrie::ID.new(input.first)
      else
        Valkyrie::ID.new(input)
      end
    end

    # Valkyrie::URI
    URI = Dry::Types::Definition
          .new(RDF::URI)
          .constructor do |input|
      if input.present?
        RDF::URI.new(input.to_s)
      else
        input
      end
    end

    # Used for casting {Valkyrie::Resources} if possible.
    Anything = Valkyrie::Types::Any.constructor do |value|
      if value.respond_to?(:fetch) && value.fetch(:internal_resource, nil)
        value.fetch(:internal_resource).constantize.new(value)
      else
        value
      end
    end

    Array = Dry::Types['array'].constructor do |value|
      ::Array.wrap(value)
    end.default([].freeze)

    # Represents an array of unique values.
    Set = Array.constructor do |value|
      ::Array.wrap(value).select(&:present?).uniq.map do |val|
        Anything[val]
      end
    end.default([].freeze)

    # Used for when an input may be an array, but the output needs to be a
    # single string.
    SingleValuedString = Valkyrie::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end
  end
end
