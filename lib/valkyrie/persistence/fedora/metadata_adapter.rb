# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  # Metadata Adapter for Fedora adapter.
  #
  # @example Instantiate with connection to Fedora.
  #   Valkyrie::Persistence::Fedora::MetadataAdapter.new(
  #     connection: ::Ldp::Client.new("http://localhost:8988/rest"),
  #     base_path: "test_fed",
  #     schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new(title: RDF::URI("http://bad.com/title"))
  #   )
  class MetadataAdapter
    attr_reader :connection, :base_path, :schema
    def initialize(connection:, base_path: "/", schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new)
      @connection = connection
      @base_path = base_path
      @schema = schema
    end

    def query_service
      @query_service ||= Valkyrie::Persistence::Fedora::QueryService.new(adapter: self)
    end

    def persister
      Valkyrie::Persistence::Fedora::Persister.new(adapter: self)
    end

    def id
      @id ||= Valkyrie::ID.new(Digest::MD5.hexdigest(connection_prefix))
    end

    def resource_factory
      Valkyrie::Persistence::Fedora::Persister::ResourceFactory.new(adapter: self)
    end

    def uri_to_id(uri)
      Valkyrie::ID.new(CGI.unescape(uri.to_s.gsub(/^.*\//, '')))
    end

    def id_to_uri(id)
      RDF::URI("#{connection_prefix}/#{pair_path(id)}/#{CGI.escape(id.to_s)}")
    end

    def pair_path(id)
      id.to_s.split(/[-\/]/).first.split("").each_slice(2).map(&:join).join("/")
    end

    def connection_prefix
      "#{connection.http.url_prefix}/#{base_path}"
    end
  end
end
