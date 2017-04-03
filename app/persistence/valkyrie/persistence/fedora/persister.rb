# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    class << self
      delegate :save, :delete, to: :instance
      def save(model:)
        instance(model).save
      end

      def delete(model:)
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
        member_predicate = orm_object.association(:members).reflection.options[:has_member_relation]
        new_member_ids.each do |member|
          # orm_object.members_will_change!
          orm_object.resource << [orm_object.resource.rdf_subject, member_predicate, ActiveFedora::Base.id_to_uri(member)]
          length = orm_object.ordered_member_proxies.to_a.length
          orm_object.ordered_member_proxies.insert_target_id_at(length, member)
        end
      end

      def new_member_ids
        member_ids - orm_member_ids
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
