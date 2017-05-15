# frozen_string_literal: true
module Valkyrie
  module Types
    include Dry::Types.module
    ID = Dry::Types::Definition
         .new(Valkyrie::ID)
         .constructor { |input| ::Valkyrie::ID.new(input) }
  end
end
