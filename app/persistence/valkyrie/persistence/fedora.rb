# frozen_string_literal: true
module Valkyrie::Persistence
  module Fedora
    def persister
      Valkyrie::Persistence::Fedora::Persister
    end

    def query_service
      Valkyrie::Persistence::Fedora::QueryService
    end

    def resource_factory
      Valkyrie::Persistence::Fedora::ResourceFactory
    end

    module_function :persister, :query_service, :resource_factory
  end
end
