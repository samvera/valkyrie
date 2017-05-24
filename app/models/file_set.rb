# frozen_string_literal: true
class FileSet < Valkyrie::Model
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title, Valkyrie::Types::Set
  attribute :file_identifiers, Valkyrie::Types::Set
  attribute :member_ids, Valkyrie::Types::Array
end
