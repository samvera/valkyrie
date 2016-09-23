# frozen_string_literal: true
class NonBlankArray < Virtus::Attribute
  def coerce(value)
    Array.wrap(value).select(&:present?)
  end
end
