# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm_syncer'
require 'valkyrie/persistence/postgres/orm'
require 'valkyrie/persistence/postgres/resource_factory'
module Valkyrie::Persistence::Postgres
  class Persister
    class << self
      def save(model:)
        instance(model).persist
      end

      # (see Valkyrie::Persistence::Memory::Persister#save_all)
      def save_all(models:)
        models.map do |model|
          save(model: model)
        end
      end

      def delete(model:)
        instance(model).delete
      end

      def sync_object(model)
        ::Valkyrie::Persistence::Postgres::ORMSyncer.new(model: model)
      end

      def adapter
        Valkyrie::Persistence::Postgres::Adapter
      end

      def instance(model)
        new(sync_object: sync_object(model))
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
