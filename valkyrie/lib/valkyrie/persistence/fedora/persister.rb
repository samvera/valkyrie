# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    require 'valkyrie/persistence/fedora/persister/resource_factory'
    attr_reader :adapter
    delegate :connection, :base_path, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def save(resource:)
      initialize_repository
      resource.created_at ||= Time.current
      resource.updated_at ||= Time.current
      orm = resource_factory.from_resource(resource: resource, adapter: adapter)
      if !orm.new? || resource.id
        orm.update do |req|
          req.headers["Prefer"] = "handling=lenient; received=\"minimal\""
        end
      else
        orm.create
      end
      resource_factory.to_resource(object: orm, adapter: adapter)
    end

    def save_all(resources:)
      resources.map do |resource|
        save(resource: resource)
      end
    end

    def delete(resource:)
      orm = resource_factory.from_resource(resource: resource, adapter: adapter)
      orm.delete
      resource
    end

    def resource_factory
      ResourceFactory
    end

    def initialize_repository
      @initialized ||=
        begin
          resource = ::Ldp::Container::Basic.new(connection, base_path, nil, base_path)
          resource.save if resource.new?
          true
        end
    end
  end
end
