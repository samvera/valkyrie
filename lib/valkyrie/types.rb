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
      if value.is_a?(::Hash)
        if value.empty?
          []
        else
          [value]
        end
      else
        ::Array.wrap(value)
      end
    end.default([].freeze)

    # Represents an array of unique values.
    Set = Array.constructor do |value|
      value = Array[value]
      clean_values = value.reject do |val|
        val == '' || (val.is_a?(Valkyrie::ID) && val.to_s == '')
      end.reject(&:nil?).uniq

      clean_values.map do |val|
        Anything[val]
      end
    end.default([].freeze)

    module ArrayDefault
      def of(type)
        super.default([].freeze)
      end

      def member(type)
        super.default([].freeze)
      end
    end
    Array.singleton_class.include(ArrayDefault)
    Set.singleton_class.include(ArrayDefault)

    # Used for when an input may be an array, but the output needs to be a
    # single string.
    SingleValuedString = Valkyrie::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end
  end
end
