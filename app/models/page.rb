# frozen_string_literal: true
class Page
  include Virtus.model
  include Valkyrie::ActiveModel
  attribute :id, String
  attribute :title, UniqueNonBlankArray
  attribute :viewing_hint, UniqueNonBlankArray
end
