# frozen_string_literal: true
class Page
  include Valkyrie::ActiveModel
  attribute :id, Valkyrie::ID::Attribute
  attribute :title, UniqueNonBlankArray
  attribute :viewing_hint, UniqueNonBlankArray
end
