# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    class << self
      def save(model)
        obj = resource_factory.from_model(model)
        obj.attributes = model.attributes.except(:id, :member_ids)
        member_ids = model.attributes.delete(:member_ids)
        if member_ids
          obj.ordered_members = member_ids.map do |member_id|
            resource_factory.from_model(query_service.find_by_id(member_id))
          end
        end
        obj.save!
        if model.respond_to?(:append_id) && model.append_id.present?
          resource = ::Valkyrie::Persistence::Fedora::ORM::Resource.find(model.append_id)
          resource.ordered_members << obj
          resource.save!
        end
        ::Valkyrie::Persistence::Fedora::ResourceFactory.to_model(obj)
      end

      def resource_factory
        ::ResourceFactory.new(adapter: Valkyrie::Persistence::Fedora)
      end

      def query_service
        ::QueryService.new(adapter: Valkyrie::Persistence::Fedora)
      end
    end
  end
end
