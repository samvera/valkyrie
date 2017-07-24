# frozen_string_literal: true
class FileSetChangeSet < Valkyrie::ChangeSet
  self.fields = FileSet.fields - [:id, :internal_resource, :created_at, :updated_at]
  property :files, virtual: true, multiple: true
end
