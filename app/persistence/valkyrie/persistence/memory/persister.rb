module Valkyrie::Persistence::Memory
  class Persister
    attr_reader :adapter
    delegate :cache, to: :adapter
    def initialize(adapter)
      @adapter = adapter
    end

    def save(model)
      model.id ||= SecureRandom.uuid
      cache[model.id] = model
    end
  end
end
