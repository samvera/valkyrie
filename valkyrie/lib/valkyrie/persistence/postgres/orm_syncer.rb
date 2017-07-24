# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  ##
  # Synchronizes a Valkyrie resource with an ActiveRecord ORM resource.
  class ORMSyncer
    attr_reader :resource
    # @param resource [Valkyrie::Resource]
    def initialize(resource:)
      @resource = resource
    end

    # @return [Valkyrie::Resource]
    def save
      orm_object.save! && rebuild_resource
    end

    def delete
      orm_object.delete && rebuild_resource
    end

    private

      def orm_object
        @orm_object ||= resource_factory.from_resource(resource)
      end

      def rebuild_resource
        @resource = resource_factory.to_resource(orm_object)
      end

      def resource_factory
        Valkyrie::Persistence::Postgres::ResourceFactory
      end
  end
end
