# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindAllQuery
    attr_reader :model
    def initialize(model: nil)
      @model = model
    end

    def run
      relation.lazy.map do |orm_object|
        ::Valkyrie::Persistence::Postgres::ResourceFactory.to_resource(orm_object)
      end
    end

    private

      def relation
        if !model
          orm_resource.all
        else
          orm_resource.where(internal_resource: model.to_s)
        end
      end

      def orm_resource
        Valkyrie::Persistence::Postgres::ORM::Resource
      end
  end
end
