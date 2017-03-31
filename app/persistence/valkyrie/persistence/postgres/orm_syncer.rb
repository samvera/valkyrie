# frozen_string_literal: true
module Penguin::Persistence::Postgres
  class ORMSyncer
    attr_reader :model
    def initialize(model:)
      @model = model
    end

    def save
      orm_object.save! && rebuild_model
    end

    def delete
      orm_object.delete && rebuild_model
    end

    private

      def orm_object
        @orm_object ||= resource_factory.from_model(model)
      end

      def rebuild_model
        @model = resource_factory.to_model(orm_object)
      end

      def resource_factory
        ::ResourceFactory.new(adapter: Penguin::Persistence::Postgres)
      end
  end
end
