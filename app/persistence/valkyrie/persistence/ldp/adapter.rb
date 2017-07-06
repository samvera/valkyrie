# frozen_string_literal: true
module Valkyrie::Persistence::LDP
  class Adapter
    attr_reader :url, :base_container
    def initialize(url:, base_container:)
      @url = url
      @base_container = base_container
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

    def uri_to_id(uri)
      uri.to_s.gsub(connection.http.url_prefix.to_s, '').gsub(/^\//, '')
    end
  end
end
