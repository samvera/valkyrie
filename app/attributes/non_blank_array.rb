class NonBlankArray < Virtus::Attribute
  def coerce(value)
    Array.wrap(value).select(&:present?)
  end
end
