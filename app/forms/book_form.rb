class BookForm < Reform::Form
  validate :title_not_empty
  property :id
  property :title

  def [](key)
    send(key) if respond_to?(key)
  end

  private

    def title_not_empty
      return unless title && title.kind_of?(Array) && title.select(&:present?).blank?
      errors.add(:title, "can not be blank.")
    end
end
