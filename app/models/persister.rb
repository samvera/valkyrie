class Persister
  @@cache = {}
  def self.cache
    @@cache
  end
  class << self
    def save(model)
      model.id = SecureRandom.uuid unless model.id
      cache[model.id] = model
      model
    end

    def find(_klass, id)
      cache[id] || raise("Object not found")
    end
  end
end
