# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm'
require 'valkyrie/persistence/postgres/resource_factory'
module Valkyrie::Persistence::Postgres
  # Persister for Postgres MetadataAdapter.
  class Persister
    attr_reader :adapter
    delegate :resource_factory, to: :adapter

    # @note (see Valkyrie::Persistence::Memory::Persister#initialize)
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(resource:)
      orm_object = resource_factory.from_resource(resource: resource)
      orm_object.save!
      resource_factory.to_resource(object: orm_object)
    rescue ActiveRecord::StaleObjectError
      raise Valkyrie::Persistence::StaleObjectError, "The object #{resource.id} has been updated by another process."
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      resource_factory.orm_class.transaction do
        resources.map do |resource|
          save(resource: resource)
        end
      end
    rescue Valkyrie::Persistence::StaleObjectError
      raise Valkyrie::Persistence::StaleObjectError, "One or more resources have been updated by another process."
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(resource:)
      orm_object = resource_factory.from_resource(resource: resource)
      orm_object.delete
      resource
    end

    # (see Valkyrie::Persistence::Memory::Persister#wipe!)
    def wipe!
      resource_factory.orm_class.delete_all
    end
  end
end
