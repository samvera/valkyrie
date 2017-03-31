# frozen_string_literal: true
class NullPersister
  class << self
    def save(model:)
      model
    end
  end

  def initialize(model:, **_extra_args)
    @model = model
  end

  def persist
    @model
  end
end
