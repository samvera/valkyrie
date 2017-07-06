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

    def find_all
      ::Ldp::Container::Basic.new(client, adapter.base_container, nil, adapter.base_container).graph.query(predicate: RDF::Vocab::LDP.contains).lazy.map do |s|
        find_by(id: adapter.uri_to_id(s.object))
      end
    end

    def find_parents(model:)
      find_all.select do |potential_parent|
        potential_parent.member_ids.include?(model.id)
      end
    end

    def client
      adapter.connection
    end
  end
end
