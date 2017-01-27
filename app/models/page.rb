# frozen_string_literal: true
class Page
  include Valkyrie::ActiveModel
  attribute :id, String
  attribute :title, UniqueNonBlankArray
  attribute :viewing_hint, UniqueNonBlankArray
end
