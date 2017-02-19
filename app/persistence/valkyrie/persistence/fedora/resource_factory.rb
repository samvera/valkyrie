module Valkyrie::Persistence::Fedora
  class ResourceFactory
    class << self
      def to_model(orm_obj)
        ::Valkyrie::Persistence::Fedora::DynamicKlass.new(orm_obj)
      end

      def from_model(model)
        resource = 
          begin
            ::Valkyrie::Persistence::Fedora::ORM::Resource.find(model.id)
          rescue
            ::Valkyrie::Persistence::Fedora::ORM::Resource.new
          end
        resource.internal_model = [model.class.to_s]
        resource
      end
    end
  end
end
