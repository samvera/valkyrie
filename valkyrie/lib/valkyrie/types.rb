# frozen_string_literal: true
module Valkyrie
  module Types
    include Dry::Types.module
    ID = Dry::Types::Definition
         .new(Valkyrie::ID)
         .constructor do |input|
           Valkyrie::ID.new(input)
         end
    Anything = Valkyrie::Types::Any.constructor do |value|
      if value.respond_to?(:fetch) && value.fetch(:internal_model, nil)
        value.fetch(:internal_model).constantize.new(value)
      else
        value
      end
    end
    Set = Valkyrie::Types::Coercible::Array.constructor do |value|
      value.select(&:present?).uniq.map do |val|
        Anything[val]
      end
    end.default([])
    Array = Dry::Types['coercible.array'].default([])
    SingleValuedString = Valkyrie::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end
  end
end
