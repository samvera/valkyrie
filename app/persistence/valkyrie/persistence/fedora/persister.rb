# frozen_string_literal: true
module Penguin::Persistence::Fedora
  class Persister
    class << self
      delegate :save, :delete, to: :instance
      def save(model)
        instance(model).save
      end

      def delete(model)
        instance(model).delete
      end

      def append_processor(model)
        Penguin::Processors::AppendProcessor.new(form: model, persister: self)
      end

      def adapter
        Penguin::Persistence::Fedora
      end

      def instance(model)
        new(model: model)
      end
    end

    attr_reader :model
    def initialize(model:)
      @model = model
    end

    def save
      orm_object.attributes = model.attributes.except(:id, :member_ids)
      process_members if member_ids
      orm_object.save!
      @model = resource_factory.to_model(orm_object)
      model
    end

    def delete
      orm_object.delete
      orm_object
    end

    private

      def orm_object
        @orm_object ||= resource_factory.from_model(model)
      end

      def process_members
        orm_object.ordered_members = orm_member_objects
      end

      def orm_member_objects
        member_ids.map do |member_id|
          resource_factory.from_model(query_service.find_by_id(member_id))
        end
      end

      def member_ids
        model.attributes[:member_ids]
      end

      def resource_factory
        ::ResourceFactory.new(adapter: Penguin::Persistence::Fedora)
      end

      def query_service
        ::QueryService.new(adapter: Penguin::Persistence::Fedora)
      end
  end
end
