# frozen_string_literal: true
module Valkyrie::Persistence::LDP
  class Adapter
    attr_reader :url
    def initialize(url:)
      @url = url
    end

    def persister
      Valkyrie::Persistence::LDP::Persister.new(adapter: self)
    end

    def query_service
      Valkyrie::Persistence::LDP::QueryService.new(adapter: self)
    end

    def connection
      @connection ||= ::Ldp::Client.new(url, {})
    end

    def resource_factory
      Valkyrie::Persistence::LDP::ResourceFactory.new(adapter: self)
    end
  end
end
