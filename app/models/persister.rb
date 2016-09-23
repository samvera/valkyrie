# frozen_string_literal: true
class Persister
  @cache = {}
  class << self
    attr_reader :cache
    def save(model)
      model.id = SecureRandom.uuid unless model.id
      cache[model.id] = model
      model
    end
  end
  class ObjectNotFoundError < StandardError
  end
end
