# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  # Persister for Fedora MetadataAdapter.
  class Persister
    require 'valkyrie/persistence/fedora/persister/resource_factory'
    require 'valkyrie/persistence/fedora/persister/alternate_identifier'
    attr_reader :adapter
    delegate :connection, :base_path, :resource_factory, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(resource:)
      initialize_repository
      resource.created_at ||= Time.current
      resource.updated_at ||= Time.current
      orm = resource_factory.from_resource(resource: resource)
      alternate_resources = find_or_create_alternate_ids(resource)

      if !orm.new? || resource.id
        cleanup_alternate_resources(resource) if alternate_resources
        orm.update { |req| req.headers["Prefer"] = "handling=lenient; received=\"minimal\"" }
      else
        orm.create
      end
      persisted_resource = resource_factory.to_resource(object: orm)

      alternate_resources ? save_reference_to_resource(persisted_resource, alternate_resources) : persisted_resource
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      resources.map do |resource|
        save(resource: resource)
      end
    end

    # (see Valkyrie::Persistence::Memory::Persister#delete)
    def delete(resource:)
      if resource.try(:alternate_ids)
        resource.alternate_ids.each do |alternate_identifier|
          adapter.persister.delete(resource: adapter.query_service.find_by(id: alternate_identifier))
        end
      end

      orm = resource_factory.from_resource(resource: resource)
      orm.delete

      resource
    end

    # (see Valkyrie::Persistence::Memory::Persister#wipe!)
    def wipe!
      connection.delete(base_path)
      connection.delete("#{base_path}/fcr:tombstone")
    rescue => error
      Valkyrie.logger.debug("Failed to wipe Fedora for some reason.") unless error.is_a?(::Ldp::NotFound)
    end

    def initialize_repository
      @initialized ||=
        begin
          resource = ::Ldp::Container::Basic.new(connection, base_path, nil, base_path)
          resource.save if resource.new?
          true
        end
    end

    private

      def find_or_create_alternate_ids(resource)
        return nil unless resource.try(:alternate_ids)

        resource.alternate_ids.map do |alternate_identifier|
          begin
            adapter.query_service.find_by(id: alternate_identifier)
          rescue ::Valkyrie::Persistence::ObjectNotFoundError
            alternate_resource = ::Valkyrie::Persistence::Fedora::AlternateIdentifier.new(id: alternate_identifier)
            adapter.persister.save(resource: alternate_resource)
          end
        end
      end

      def cleanup_alternate_resources(updated_resource)
        persisted_resource = adapter.query_service.find_by(id: updated_resource.id)
        removed_identifiers = persisted_resource.alternate_ids - updated_resource.alternate_ids

        removed_identifiers.each do |removed_id|
          adapter.persister.delete(resource: adapter.query_service.find_by(id: removed_id))
        end
      end

      def save_reference_to_resource(resource, alternate_resources)
        alternate_resources.each do |alternate_resource|
          alternate_resource.references = resource.id
          adapter.persister.save(resource: alternate_resource)
        end

        resource
      end
  end
end
