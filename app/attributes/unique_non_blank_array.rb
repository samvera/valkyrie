# frozen_string_literal: true
class UniqueNonBlankArray < Virtus::Attribute
  def coerce(value)
    Array.wrap(value).select(&:present?).uniq
  end
end
