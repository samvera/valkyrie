# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class Adapter
    attr_writer :cache
    def resource_factory; end

    def persister
      Valkyrie::Persistence::Memory::Persister.new(self)
    end

    def query_service
      Valkyrie::Persistence::Memory::QueryService.new(adapter: self)
    end

    def cache
      @cache ||= {}
    end
  end
end
