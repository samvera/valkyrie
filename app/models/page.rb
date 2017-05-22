# frozen_string_literal: true
class Page < Valkyrie::Model
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
  attribute :viewing_hint, Valkyrie::Types::Set
end
