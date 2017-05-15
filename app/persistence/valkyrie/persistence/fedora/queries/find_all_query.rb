# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Queries
  class FindAllQuery
    attr_reader :model
    def initialize(model: nil)
      @model = model
    end

    def run
      relation.lazy.map do |orm_object|
        resource_factory.to_model(orm_object)
      end
    end

    private

      def relation
        if !model
          orm_model.all
        else
          orm_model.where(internal_model: model.to_s)
        end
      end

      def orm_model
        Valkyrie::Persistence::Fedora::ORM::Resource
      end

      def resource_factory
        ::Valkyrie::Persistence::Fedora::ResourceFactory
      end
  end
end
