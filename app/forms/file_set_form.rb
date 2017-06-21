# frozen_string_literal: true
class FileSetForm < Valkyrie::Form
  self.fields = FileSet.fields - [:id, :internal_model]
end
