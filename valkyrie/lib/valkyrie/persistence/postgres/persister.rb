# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm'
require 'valkyrie/persistence/postgres/resource_factory'
module Valkyrie::Persistence::Postgres
  class Persister
    attr_reader :adapter
    delegate :resource_factory, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(resource:)
      orm_object = resource_factory.from_resource(resource: resource)
      orm_object.save!
      resource_factory.to_resource(object: orm_object)
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      resources.map do |resource|
        save(resource: resource)
      end
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(resource:)
      orm_object = resource_factory.from_resource(resource: resource)
      orm_object.delete
      resource
    end
  end
end
