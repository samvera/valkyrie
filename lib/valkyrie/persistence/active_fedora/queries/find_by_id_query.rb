# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora::Queries
  class FindByIdQuery
    attr_reader :id
    def initialize(id)
      @id = id
    end

    def run
      ::Valkyrie::Persistence::ActiveFedora::ResourceFactory.to_resource(relation)
    rescue ActiveFedora::ObjectNotFoundError, ::Ldp::Gone
      raise Valkyrie::Persistence::ObjectNotFoundError
    end

    private

      def relation
        orm_resource.find(id.to_s)
      end

      def orm_resource
        ::Valkyrie::Persistence::ActiveFedora::ORM::Resource
      end
  end
end
