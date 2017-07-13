# frozen_string_literal: true
class FileSetForm < Valkyrie::Form
  self.fields = FileSet.fields - [:id, :internal_model, :created_at, :updated_at]
  property :files, virtual: true, multiple: true
end
