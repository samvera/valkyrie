# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  # Persister for Fedora MetadataAdapter.
  class Persister
    require 'valkyrie/persistence/fedora/persister/resource_factory'
    require 'valkyrie/persistence/fedora/persister/alternate_identifier'
    attr_reader :adapter
    delegate :connection, :base_path, :resource_factory, to: :adapter

    # @note (see Valkyrie::Persistence::Memory::Persister#initialize)
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::Persister#save)
    def save(resource:)
      initialize_repository
      internal_resource = resource.dup
      internal_resource.created_at ||= Time.current
      internal_resource.updated_at ||= Time.current
      validate_lock_token(internal_resource)
      native_lock = native_lock_token(internal_resource)
      generate_lock_token(internal_resource)
      orm = resource_factory.from_resource(resource: internal_resource)
      alternate_resources = find_or_create_alternate_ids(internal_resource)

      if !orm.new? || internal_resource.id
        cleanup_alternate_resources(internal_resource) if alternate_resources
        orm.update { |req| update_request_headers(req, native_lock) }
      else
        orm.create
      end
      persisted_resource = resource_factory.to_resource(object: orm)

      alternate_resources ? save_reference_to_resource(persisted_resource, alternate_resources) : persisted_resource
    rescue Ldp::PreconditionFailed
      raise Valkyrie::Persistence::StaleObjectError, "The object #{internal_resource.id} has been updated by another process."
    end

    # (see Valkyrie::Persistence::Memory::Persister#save_all)
    def save_all(resources:)
      resources.map do |resource|
        save(resource: resource)
      end
    rescue Valkyrie::Persistence::StaleObjectError
      # blank out the message / id
      raise Valkyrie::Persistence::StaleObjectError, "One or more resources have been updated by another process."
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

      # @note Fedora's last modified response is not granular enough to produce an effective lock token
      #   therefore, we use the same implementation as the memory adapter. This could fail to lock a
      #   resource if Fedora updated this resource between the time it was saved and Valkyrie created
      #   the token.
      def generate_lock_token(resource)
        return unless resource.optimistic_locking_enabled?
        token = Valkyrie::Persistence::OptimisticLockToken.new(adapter_id: adapter.id, token: Time.now.to_r)
        resource.send("#{Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK}=", token)
      end

      def validate_lock_token(resource)
        return unless resource.optimistic_locking_enabled?
        return if resource.id.blank?

        current_lock_token = resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK].find { |lock_token| lock_token.adapter_id == adapter.id }
        return if current_lock_token.blank?

        retrieved_lock_tokens = adapter.query_service.find_by(id: resource.id)[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK]
        retrieved_lock_token = retrieved_lock_tokens.find { |lock_token| lock_token.adapter_id == adapter.id }
        return if retrieved_lock_token.blank?

        raise Valkyrie::Persistence::StaleObjectError, "The object #{resource.id} has been updated by another process." unless current_lock_token == retrieved_lock_token
      end

      # Retrieve the lock token that holds Fedora's system-managed last-modified date
      def native_lock_token(resource)
        return unless resource.optimistic_locking_enabled?
        resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK].find { |lock_token| lock_token.adapter_id == "native-#{adapter.id}" }
      end

      # Set Fedora request headers:
      # * `Prefer: handling=lenient; received="minimal"` allows us to avoid sending all server-managed triples
      # * `If-Unmodified-Since` triggers Fedora's server-side optimistic locking
      def update_request_headers(request, lock_token)
        request.headers["Prefer"] = "handling=lenient; received=\"minimal\""
        request.headers["If-Unmodified-Since"] = lock_token.token if lock_token
      end
  end
end
