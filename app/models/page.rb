# frozen_string_literal: true
class Page < Valkyrie::Model
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
  attribute :viewing_hint, Valkyrie::Types::Set
  attribute :read_groups, Valkyrie::Types::Set
  attribute :read_users, Valkyrie::Types::Set
  attribute :edit_users, Valkyrie::Types::Set
  attribute :edit_groups, Valkyrie::Types::Set
end
