# frozen_string_literal: true
class FileNode < Valkyrie::Model
  include Valkyrie::Model::AccessControls
  attribute :id, Valkyrie::Types::ID.optional
  attribute :label, Valkyrie::Types::Set
  attribute :mime_type, Valkyrie::Types::Set
  attribute :original_filename, Valkyrie::Types::Set
  attribute :file_identifiers, Valkyrie::Types::Set
end
