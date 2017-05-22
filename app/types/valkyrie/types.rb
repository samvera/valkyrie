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
    end
  end
end
