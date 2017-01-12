# frozen_string_literal: true
class Book
  attr_accessor :append_id
  include Virtus.model
  include Valkyrie::ActiveModel
  attribute :id, String
  attribute :title, UniqueNonBlankArray
  attribute :author, UniqueNonBlankArray
  attribute :testing, UniqueNonBlankArray
  attribute :member_ids, NonBlankArray
end
