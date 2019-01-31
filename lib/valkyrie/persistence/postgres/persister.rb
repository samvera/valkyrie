# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm'
require 'valkyrie/persistence/postgres/resource_factory'
require 'uuid'

module Valkyrie::Persistence::Postgres
  # Persister for Postgres MetadataAdapter.
  class Persister
    attr_reader :adapter
    delegate :resource_factory, to: :adapter

    # @param [MetadataAdapter] adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    # Persists a resource within the database
    # @param [Valkyrie::Resource] resource
    # @param [TrueClass || FalseClass] force Suppress UnsupportedDatatype and allow non-UUID ids within the resource
    #                                         to be overwritten by Postgres, which it does by default
    # @return [Valkyrie::Resource] the persisted/updated resource
    # @raise [Valkyrie::Persistence::StaleObjectError] raised if the resource
    #   was modified in the database between been read into memory and persisted
    # @raise [Valkyrie::Persistence::UnsupportedDatatype] raised if the id in the resource is set to a non-UUID
    def save(resource:, force: nil)
      unless nil_or_uuid?(resource.id)
        if force.nil?
          warn '[DEPRECATION] Suppressing UnsupportedDatatype error by default has been deprecated and will be removed in the next major release. ' \
               'Change your call to include force:true if you would like this behavior to continue.'
          force = true
        end
        raise Valkyrie::Persistence::UnsupportedDatatype, 'Postgres ids must be UUIDs. To overwrite this id use force: true' unless force
      end

      orm_object = resource_factory.from_resource(resource: resource)
      orm_object.save!
      resource_factory.to_resource(object: orm_object)
    rescue ActiveRecord::StaleObjectError
      raise Valkyrie::Persistence::StaleObjectError, "The object #{resource.id} has been updated by another process."
    end

    # Persists a set of resources within the database
    # @param [Array<Valkyrie::Resource>] resources
    # @param [TrueClass || FalseClass] force Suppress UnsupportedDatatype and allow non-UUID ids within the resource
    #                                         to be overwritten by Postgres, which it does by default
    # @return [Array<Valkyrie::Resource>] the persisted/updated resources
    # @raise [Valkyrie::Persistence::StaleObjectError] raised if the resource
    #   was modified in the database between been read into memory and persisted
    # @raise [Valkyrie::Persistence::UnsupportedDatatype] raised if the id in the resource is set to a non-UUID
    def save_all(resources:, force: nil)
      resource_factory.orm_class.transaction do
        resources.map do |resource|
          save(resource: resource, force: force)
        end
      end
    rescue Valkyrie::Persistence::StaleObjectError
      raise Valkyrie::Persistence::StaleObjectError, "One or more resources have been updated by another process."
    end

    # Deletes a resource persisted within the database
    # @param [Valkyrie::Resource] resource
    # @return [Valkyrie::Resource] the deleted resource
    def delete(resource:)
      orm_object = resource_factory.from_resource(resource: resource)
      orm_object.delete
      resource
    end

    # Deletes all resources of a specific Valkyrie Resource type persisted in
    #   the database
    def wipe!
      resource_factory.orm_class.delete_all
    end

    private

      def nil_or_uuid?(id)
        return true if id.blank?

        ::UUID.validate(id.to_s)
      end
  end
end
