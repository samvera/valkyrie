# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm_syncer'
require 'valkyrie/persistence/postgres/orm'
require 'valkyrie/persistence/postgres/resource_factory'
module Valkyrie::Persistence::Postgres
  class Persister
    class << self
      # (see Valkyrie::Persistence::Memory::Persister#save)
      def save(model:)
        new(sync_object: sync_object(model)).persist
      end

      # (see Valkyrie::Persistence::Memory::Persister#save_all)
      def save_all(models:)
        models.map do |model|
          save(model: model)
        end
      end

      # (see Valkyrie::Persistence::Memory::Persister#delete)
      def delete(model:)
        new(sync_object: sync_object(model)).delete
      end

      # @param model [Valkyrie::Model] The model to be persisted via a sync.
      # @return [Valkyrie::Persistence::Postgres::ORMSyncer] Syncer.
      def sync_object(model)
        ::Valkyrie::Persistence::Postgres::ORMSyncer.new(model: model)
      end

      # @return [Class] {Valkyrie::Persistence::Postgres::Adapter}
      def adapter
        Valkyrie::Persistence::Postgres::Adapter
      end
    end

    attr_reader :sync_object
    delegate :model, to: :sync_object

    def initialize(sync_object: nil)
      @sync_object = sync_object
    end

    def persist
      sync_object.save
      model
    end

    def delete
      sync_object.delete
      model
    end
  end
end
