# frozen_string_literal: true
class FileNode < Valkyrie::Model
  attribute :id, Valkyrie::Types::ID.optional
  attribute :label, Valkyrie::Types::Set
  attribute :file_identifiers, Valkyrie::Types::Set
  attribute :read_groups, Valkyrie::Types::Set
  attribute :read_users, Valkyrie::Types::Set
  attribute :edit_users, Valkyrie::Types::Set
  attribute :edit_groups, Valkyrie::Types::Set
end
