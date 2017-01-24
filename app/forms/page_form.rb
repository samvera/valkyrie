# frozen_string_literal: true
class PageForm < Reform::Form
  validate :title_not_empty
  def self.fields
    Page.fields - [:id]
  end

  fields.each do |attribute|
    property attribute
  end

  property :append_id, virtual: true

  def [](key)
    send(key) if respond_to?(key)
  end

  def viewing_hint
    Array(model.viewing_hint).first
  end

  private

    def title_not_empty
      return unless title && title.is_a?(Array) && title.select(&:present?).blank?
      errors.add(:title, "can not be blank.")
    end
end
