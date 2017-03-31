# frozen_string_literal: true
module Penguin::Persistence
  module Fedora
    def persister
      Penguin::Persistence::Fedora::Persister
    end

    def query_service
      Penguin::Persistence::Fedora::QueryService
    end

    def resource_factory
      Penguin::Persistence::Fedora::ResourceFactory
    end

    module_function :persister, :query_service, :resource_factory
  end
end
