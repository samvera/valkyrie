# frozen_string_literal: true
class CollectionForm < Valkyrie::Form
  self.fields = ::Collection.fields - [:id, :internal_model]
end
