# frozen_string_literal: true
class BookForm < Reform::Form
  validate :title_not_empty
  ::Book.attribute_set.map(&:name).each do |attribute|
    property attribute
  end

  def [](key)
    send(key) if respond_to?(key)
  end

  private

    def title_not_empty
      return unless title && title.is_a?(Array) && title.select(&:present?).blank?
      errors.add(:title, "can not be blank.")
    end
end
