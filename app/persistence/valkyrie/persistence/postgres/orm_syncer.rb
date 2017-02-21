# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class ORMSyncer
    delegate :orm_attributes, :model_attributes, to: :attribute_mapper
    attr_reader :model
    def initialize(model:)
      @model = model
    end

    def sync!
      orm_object.metadata.merge!(clean_attributes)
    end

    def save
      sync! && orm_object.save! && rebuild_model
    end

    private

      def attribute_mapper
        ::Valkyrie::Persistence::Postgres::AttributeMapper.new(orm_object: orm_object, model: model)
      end

      def orm_object
        @orm_object ||= resource_factory.from_model(model)
      end

      def rebuild_model
        @model = resource_factory.to_model(orm_object)
      end

      def resource_factory
        ::ResourceFactory.new(adapter: Valkyrie::Persistence::Postgres)
      end

      def clean_attributes
        model_attributes.except(:id)
      end
  end
end
