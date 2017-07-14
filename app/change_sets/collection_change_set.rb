# frozen_string_literal: true
class CollectionChangeSet < Valkyrie::ChangeSet
  self.fields = ::Collection.fields - [:id, :internal_model, :created_at, :updated_at]
end
