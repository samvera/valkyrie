# frozen_string_literal: true
class NullPersister
  class << self
    def save(resource:)
      resource
    end
  end

  def initialize(resource:, **_extra_args)
    @resource = resource
  end

  def persist
    @resource
  end
end
