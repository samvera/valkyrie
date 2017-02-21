# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    class << self
      def save(model)
        new(model: model, post_processors: [append_processor(model)]).save
      end

      def append_processor(model)
        Valkyrie::Processors::AppendProcessor::Factory.new(form: model, adapter: adapter)
      end

      def adapter
        Valkyrie::Persistence::Fedora
      end
    end

    attr_reader :model, :post_processors
    def initialize(model:, post_processors: [])
      @model = model
      @post_processors = post_processors
    end

    def save
      orm_object.attributes = model.attributes.except(:id, :member_ids)
      process_members if member_ids
      orm_object.save!
      @model = resource_factory.to_model(orm_object)
      post_processors.each do |processor|
        processor.new(persister: self).run
      end
      model
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
        ::ResourceFactory.new(adapter: Valkyrie::Persistence::Fedora)
      end

      def query_service
        ::QueryService.new(adapter: Valkyrie::Persistence::Fedora)
      end
  end
end
