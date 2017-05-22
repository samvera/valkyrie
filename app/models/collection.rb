# frozen_string_literal: true
class Collection
  include Valkyrie::Model
  attribute :id, Valkyrie::ID::Attribute
  attribute :title, UniqueNonBlankArray
end
