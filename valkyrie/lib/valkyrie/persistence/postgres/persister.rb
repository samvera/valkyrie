# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm_syncer'
require 'valkyrie/persistence/postgres/orm'
require 'valkyrie/persistence/postgres/resource_factory'
module Valkyrie::Persistence::Postgres
  class Persister
    class << self
      # (see Valkyrie::Persistence::Memory::Persister#save)
      def save(resource:)
        new(sync_object: sync_object(resource)).persist
      end

      # (see Valkyrie::Persistence::Memory::Persister#save_all)
      def save_all(resources:)
        resources.map do |resource|
          save(resource: resource)
        end
      end

      # (see Valkyrie::Persistence::Memory::Persister#delete)
      def delete(resource:)
        new(sync_object: sync_object(resource)).delete
      end

      # @param resource [Valkyrie::Resource] The resource to be persisted via a sync.
      # @return [Valkyrie::Persistence::Postgres::ORMSyncer] Syncer.
      def sync_object(resource)
        ::Valkyrie::Persistence::Postgres::ORMSyncer.new(resource: resource)
      end
    end

    attr_reader :sync_object
    delegate :resource, to: :sync_object

    def initialize(sync_object: nil)
      @sync_object = sync_object
    end

    def persist
      sync_object.save
      resource
    end

    def delete
      sync_object.delete
      resource
    end
  end
end
