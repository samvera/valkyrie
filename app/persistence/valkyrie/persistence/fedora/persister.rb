module Valkyrie::Persistence::Fedora
  class Persister
    class << self
      def save(model)
        obj = resource_factory.from_model(model)
        obj.attributes = model.attributes.except(:id, :member_ids)
        obj.save!
        if model.respond_to?(:append_id) && model.append_id.present?
          resource = ::Valkyrie::Persistence::Fedora::ORM::Resource.find(model.append_id)
          resource.members << obj
          resource.save!
        end
        ::Valkyrie::Persistence::Fedora::ResourceFactory.to_model(obj)
      end

      def resource_factory
        ::Valkyrie::Persistence::Fedora::ResourceFactory
      end
    end
  end

end
