# frozen_string_literal: true
class FileSet < Valkyrie::Model
  attribute :id, Valkyrie::ID::Attribute
  attribute :title, UniqueNonBlankArray
  attribute :file_identifiers, UniqueNonBlankArray
  attribute :member_ids, NonBlankArray
end
