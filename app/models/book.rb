# frozen_string_literal: true
class Book
  include Penguin::ActiveModel
  attribute :id, String
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
