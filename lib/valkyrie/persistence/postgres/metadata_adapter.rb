# frozen_string_literal: true
require 'valkyrie/persistence/postgres/persister'
require 'valkyrie/persistence/postgres/query_service'
module Valkyrie::Persistence::Postgres
  # Metadata Adapter for Postgres Adapter.
  #
  # This adapter uses ActiveRecord to persist resources in a JSON-B column named
  # `metadata`. This requires setting up a database.
  #
  # @see https://github.com/samvera-labs/valkyrie/wiki/Set-up-Valkyrie-database-in-a-Rails-Application
  class MetadataAdapter
    # @return [Class] {Valkyrie::Persistence::Postgres::Persister}
    def persister
      Valkyrie::Persistence::Postgres::Persister.new(adapter: self)
    end

    # @return [Class] {Valkyrie::Persistence::Postgres::QueryService}
    def query_service
      @query_service ||= Valkyrie::Persistence::Postgres::QueryService.new(
        resource_factory: resource_factory
      )
    end

    # @return [Class] {Valkyrie::Persistence::Postgres::ResourceFactory}
    def resource_factory
      @resource_factory ||= Valkyrie::Persistence::Postgres::ResourceFactory.new(adapter: self)
    end

    def id
      @id ||= begin
        to_hash = "#{resource_factory.orm_class.connection_config['host']}:#{resource_factory.orm_class.connection_config['database']}"
        Valkyrie::ID.new(Digest::MD5.hexdigest(to_hash))
      end
    end
  end
end
