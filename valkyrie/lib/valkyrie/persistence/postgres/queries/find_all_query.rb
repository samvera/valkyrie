# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindAllQuery
    attr_reader :resource
    def initialize(resource: nil)
      @resource = resource
    end

    def run
      relation.lazy.map do |orm_object|
        ::Valkyrie::Persistence::Postgres::ResourceFactory.to_resource(orm_object)
      end
    end

    private

      def relation
        if !resource
          orm_resource.all
        else
          orm_resource.where(internal_resource: resource.to_s)
        end
      end

      def orm_resource
        Valkyrie::Persistence::Postgres::ORM::Resource
      end
  end
end
