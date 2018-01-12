# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class QueryService
    attr_reader :adapter
    delegate :connection, :resource_factory, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def find_by(id:)
      validate_id(id)
      uri = adapter.id_to_uri(id)
      begin
        resource = Ldp::Resource.for(connection, uri, connection.get(uri))
        resource_factory.to_resource(object: resource)
      rescue ::Ldp::Gone, ::Ldp::NotFound
        raise ::Valkyrie::Persistence::ObjectNotFoundError
      end
    end

    def find_parents(resource:)
      content = content_with_inbound(id: resource.id)
      parent_ids = content.graph.query([nil, RDF::Vocab::ORE.proxyFor, nil]).map(&:subject).map { |x| x.to_s.gsub(/#.*/, '') }.map { |x| adapter.uri_to_id(x) }
      parent_ids.lazy.map do |id|
        find_by(id: id)
      end
    end

    def include_uris
      [
        ::RDF::Vocab::Fcrepo4.InboundReferences
      ]
    end

    def find_members(resource:, model: nil)
      return [] unless resource.respond_to? :member_ids
      result = Array(resource.member_ids).lazy.map do |id|
        find_by(id: id)
      end.select(&:present?)
      return result unless model
      result.select { |obj| obj.is_a?(model) }
    end

    def find_all
      resource = Ldp::Resource.for(connection, adapter.base_path, connection.get(adapter.base_path))
      ids = resource.graph.query([nil, RDF::Vocab::LDP.contains, nil]).map(&:object).map { |x| adapter.uri_to_id(x) }
      ids.lazy.map do |id|
        find_by(id: id)
      end
    rescue ::Ldp::NotFound
      []
    end

    def find_all_of_model(model:)
      find_all.select do |m|
        m.is_a?(model)
      end
    end

    def find_references_by(resource:, property:)
      (resource[property] || []).select { |x| x.is_a?(Valkyrie::ID) }.lazy.map do |id|
        find_by(id: id)
      end
    end

    def content_with_inbound(id:)
      uri = adapter.id_to_uri(id)
      connection.get(uri) do |req|
        prefer_headers = Ldp::PreferHeaders.new(req.headers["Prefer"])
        prefer_headers.include = prefer_headers.include | include_uris
        req.headers["Prefer"] = prefer_headers.to_s
      end
    end

    def find_inverse_references_by(resource:, property:)
      content = content_with_inbound(id: resource.id)
      property_uri =  adapter.schema.predicate_for(property: property, resource: nil)
      ids = content.graph.query([nil, property_uri, nil]).map(&:subject).map { |x| x.to_s.gsub(/#.*/, '') }.map { |x| adapter.uri_to_id(x) }
      ids.lazy.map do |id|
        find_by(id: id)
      end
    end

    def custom_queries
      @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
    end

    private

      def validate_id(id)
        raise ArgumentError, 'id must be a Valkyrie::ID' unless id.is_a? Valkyrie::ID
      end
  end
end
