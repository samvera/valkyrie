# frozen_string_literal: true
module Valkyrie::Persistence::LDP
  class QueryService
    attr_reader :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def find_by(id:)
      source = ::Ldp::Resource::RdfSource.new(client, "/#{id}")
      raise ::Persister::ObjectNotFoundError if source.new?
      adapter.resource_factory.to_model(source)
    rescue ::Ldp::Gone
      raise ::Persister::ObjectNotFoundError
    end

    def find_members(model:)
      model.member_ids.map do |id|
        find_by(id: id)
      end
    end

    def client
      adapter.connection
    end
  end
end
