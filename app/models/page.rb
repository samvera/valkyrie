# frozen_string_literal: true
class Page
  include Valkyrie::Model
  attribute :id, Valkyrie::ID::Attribute
  attribute :title, UniqueNonBlankArray
  attribute :viewing_hint, UniqueNonBlankArray
end
