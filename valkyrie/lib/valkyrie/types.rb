# frozen_string_literal: true
module Valkyrie
  ##
  # Namespace for Dry::Types types.
  module Types
    include Dry::Types.module
    # Valkyrie::ID
    ID = Dry::Types::Definition
         .new(Valkyrie::ID)
         .constructor do |input|
           Valkyrie::ID.new(input)
         end
    # Used for casting {Valkyrie::Models} if possible.
    Anything = Valkyrie::Types::Any.constructor do |value|
      if value.respond_to?(:fetch) && value.fetch(:internal_model, nil)
        value.fetch(:internal_model).constantize.new(value)
      else
        value
      end
    end
    # Represents an array of unique values.
    Set = Valkyrie::Types::Coercible::Array.constructor do |value|
      value.select(&:present?).uniq.map do |val|
        Anything[val]
      end
    end.default([])
    Array = Dry::Types['coercible.array'].default([])
    # Used for when an input may be an array, but the output needs to be a
    # single string.
    SingleValuedString = Valkyrie::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end
  end
end
