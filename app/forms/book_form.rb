# frozen_string_literal: true
class BookForm < Valkyrie::Form
  validate :title_not_empty
  self.fields = Book.fields - [:id, :internal_model]
  property :title, required: true
  property :files, virtual: true, multiple: true
  property :viewing_hint, multiple: false
  property :viewing_direction, multiple: false
  property :member_ids, multiple: true, type: Types::Strict::Array.member(Valkyrie::Types::ID)
  property :a_member_of, multiple: true, type: Types::Strict::Array.member(Valkyrie::Types::ID)
  property :thumbnail_id, multiple: false, type: Valkyrie::Types::ID
  property :start_canvas, multiple: false, type: Valkyrie::Types::ID

  private

    def title_not_empty
      return unless title && title.is_a?(Array) && title.select(&:present?).blank?
      errors.add(:title, "can not be blank.")
    end
end
