# frozen_string_literal: true
class Book
  include Valkyrie::ActiveModel
  attribute :id, Valkyrie::ID::Attribute
  attribute :title, UniqueNonBlankArray
  attribute :author, UniqueNonBlankArray
  attribute :testing, UniqueNonBlankArray
  attribute :member_ids, NonBlankArray
  attribute :viewing_hint, UniqueNonBlankArray
  attribute :viewing_direction, UniqueNonBlankArray
  attribute :thumbnail_id, UniqueNonBlankArray
  attribute :representative_id, UniqueNonBlankArray
  attribute :start_canvas, UniqueNonBlankArray
end
