# frozen_string_literal: true
class FileNode < Valkyrie::Model
  attribute :id, Valkyrie::ID::Attribute
  attribute :label, UniqueNonBlankArray
  attribute :file_identifiers, UniqueNonBlankArray
end
