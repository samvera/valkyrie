# frozen_string_literal: true
class CollectionForm < Valkyrie::Form
  self.fields = ::Collection.fields - [:id]
end
