# frozen_string_literal: true
class UniqueNonBlankArray < Virtus::Attribute
  def coerce(value)
    if !value.respond_to?(:each)
      Array.wrap(value)
    else
      value
    end.select(&:present?).uniq
  end
end
