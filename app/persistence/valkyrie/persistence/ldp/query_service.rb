# frozen_string_literal: true
module Valkyrie::Persistence::LDP
  class QueryService
    attr_reader :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def find_by(id:)
      adapter.resource_factory.to_model(::Ldp::Resource::RdfSource.new(client, "/#{id}"))
    end

    def client
      adapter.connection
    end
  end
end
