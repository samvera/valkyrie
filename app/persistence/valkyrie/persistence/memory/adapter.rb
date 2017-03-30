module Valkyrie::Persistence::Memory
  class Adapter
    def resource_factory
    end

    def persister
      Valkyrie::Persistence::Memory::Persister.new(self)
    end

    def query_service
      Valkyrie::Persistence::Memory::QueryService.new(self)
    end

    def cache
      @cache ||= {}
    end
  end
end
