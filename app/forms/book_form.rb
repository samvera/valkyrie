# frozen_string_literal: true
class BookForm < Valkyrie::Form
  validate :title_not_empty
  self.fields = Book.fields - [:id]

  def viewing_hint
    Array(model.viewing_hint).first
  end

  def viewing_direction
    Array(model.viewing_direction).first
  end

  def thumbnail_id
    Array(model.thumbnail_id).first
  end

  def start_canvas
    Array(model.start_canvas).first
  end

  private

    def title_not_empty
      return unless title && title.is_a?(Array) && title.select(&:present?).blank?
      errors.add(:title, "can not be blank.")
    end
end
