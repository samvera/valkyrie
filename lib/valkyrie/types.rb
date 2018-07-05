# frozen_string_literal: true
module Valkyrie
  # Namespace for Dry::Types types.
  #  Includes Dry::Types built-in types and defines custom Valkyrie types
  #
  # Types allow your models to automatically cast attributes to the appropriate type
  # or even fail to instantiate should you give an inappropriate type.
  #
  # @example Use types in property definitions on a resource
  #   class Book < Valkyrie::Resource
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

    # Optimistic Lock Token
    OptimisticLockToken =
      Dry::Types::Definition
      .new(::Valkyrie::Persistence::OptimisticLockToken)
      .constructor do |input|
        Valkyrie::Persistence::OptimisticLockToken.deserialize(input)
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
        warn "[DEPRECATION] .member has been removed by dry-types and will be removed in the next " \
             "major version of Valkyrie. Please use .of instead. " \
             "Called from #{Gem.location_of_caller.join(':')}"
        of(type).default([].freeze)
      end

      # Override optional to provide a default because without it an
      # instantiated Valkyrie::Resource's internal hash does not have values for
      # every possible attribute, resulting in `MissingAttributeError`.
      def optional
        super.default(nil)
      end
    end
    Array.singleton_class.include(ArrayDefault)
    Set.singleton_class.include(ArrayDefault)

    # Used for when an input may be an array, but the output needs to be a
    # single string.
    SingleValuedString = Valkyrie::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end

    Int = Valkyrie::Types::Integer.constructor do |value|
      warn "[DEPRECATION] Valkyrie::Types::Int has been renamed in dry-types and this " \
           "reference will be removed in the next major version of Valkyrie. Please use " \
           "Valkyrie::Types::Integer instead. " \
           "Called from #{Gem.location_of_caller.join(':')}"
      Valkyrie::Types::Integer[value]
    end
    Coercible::Int = Valkyrie::Types::Coercible::Integer.constructor do |value|
      warn "[DEPRECATION] Valkyrie::Types::Coercible::Int has been renamed in dry-types and this " \
           "reference will be removed in the next major version of Valkyrie. Please use " \
           "Valkyrie::Types::Coercible::Integer instead. " \
           "Called from #{Gem.location_of_caller.join(':')}"
      Valkyrie::Types::Coercible::Integer[value]
    end
  end

  # Patches member back in until the next major version of Valkyrie.
  Dry::Types::Array.send(:define_method, :member) do |type|
    warn "[DEPRECATION] .member has been removed by dry-types and will be removed in the next " \
      "major version of Valkyrie. Please use .of instead. " \
      "Called from #{Gem.location_of_caller.join(':')}"
    of(type)
  end
end
