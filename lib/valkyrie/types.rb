# frozen_string_literal: true
module Valkyrie
  module Types
    include Dry::Types.module
    ID = Dry::Types::Definition
         .new(Valkyrie::ID)
         .constructor do |input|
           Valkyrie::ID.new(input)
         end
    Set = Valkyrie::Types::Coercible::Array.constructor do |value|
      value.select(&:present?).uniq
    end.default([])
    Array = Dry::Types['coercible.array'].default([])
    SingleValuedString = Valkyrie::Types::String.constructor do |value|
      ::Array.wrap(value).first.to_s
    end
  end
end
