# frozen_string_literal: true
class BookForm < Valkyrie::Form
  validate :title_not_empty
  self.fields = Book.fields - [:id]
  property :files, virtual: true

  def member_ids=(member_ids)
    super Array.wrap(member_ids).map { |x| Valkyrie::ID.new(x) }
  end

  def viewing_hint
    Array(model.viewing_hint).first
  end

  def viewing_direction
    Array(model.viewing_direction).first
  end

  def thumbnail_id
    Array(super).first
  end

  def thumbnail_id=(id)
    super(Valkyrie::ID.new(id.to_s))
  end

  def start_canvas
    Array(super).first
  end

  def start_canvas=(id)
    super(Valkyrie::ID.new(id.to_s))
  end

  private

    def title_not_empty
      return unless title && title.is_a?(Array) && title.select(&:present?).blank?
      errors.add(:title, "can not be blank.")
    end
end
