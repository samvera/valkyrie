# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    class << self
      delegate :save, :delete, to: :instance
      def save(model:)
        instance(model).save
      end

      def delete(model)
        instance(model).delete
      end

      def adapter
        Valkyrie::Persistence::Fedora
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
        new_members.each do |member|
          orm_object.ordered_members << member
        end
      end

      def new_members
        (member_ids - orm_member_ids).map do |member_id|
          ActiveFedora::Base.find(member_id)
        end
      end

      def orm_member_ids
        orm_object.ordered_member_proxies.map do |member|
          ActiveFedora::Base.uri_to_id(member.target_uri)
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
