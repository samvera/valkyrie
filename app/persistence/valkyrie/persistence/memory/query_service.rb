module Valkyrie::Persistence::Memory
  class QueryService
    attr_reader :adapter
    delegate :cache, to: :adapter
    def initialize(adapter)
      @adapter = adapter
    end

    def find_by_id(id)
      cache[id]
    end
  end
end
