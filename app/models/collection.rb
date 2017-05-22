# frozen_string_literal: true
class Collection < Valkyrie::Model
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
end
