# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class BulkSyncer
    attr_reader :models
    def initialize(models:)
      @models = models
    end

    def save_all
      new_result = orm_klass.import(new_resources)
      existing_result = orm_klass.import(existing_resources, on_duplicate_key_update: [:metadata])
      orm_klass.where(id: (new_result.ids + existing_result.ids)).map do |resource|
        resource_factory.to_model(resource)
      end
    end

    private

      def all_resources
        new_resources + existing_resources
      end

      def new_resources
        @new_resources ||= models.select { |x| !orm_ids.include?(x.id) }.map do |model|
          resource_factory.from_model(model, resource: orm_klass.new)
        end
      end

      def existing_resources
        @existing_resources ||= orm_resources.map do |resource|
          resource_factory.from_model(grouped_models[Valkyrie::ID.new(resource.id)].first, resource: resource)
        end
      end

      def orm_resources
        @orm_resources ||= orm_klass.where(id: models.map(&:id))
      end

      def grouped_models
        @grouped_resources ||= models.group_by(&:id)
      end

      def orm_ids
        @orm_ids ||= orm_resources.map { |x| Valkyrie::ID.new(x.id) }
      end

      def orm_klass
        ::Valkyrie::Persistence::Postgres::ORM::Resource
      end

      def resource_factory
        Valkyrie::Persistence::Postgres::ResourceFactory
      end
  end
end
