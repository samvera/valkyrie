# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindInverseReferencesQuery
    attr_reader :obj, :property
    def initialize(obj, property)
      @obj = obj
      @property = property
    end

    def run
      relation.lazy.map do |orm_object|
        resource_factory.to_resource(orm_object)
      end
    end

    private

      def relation
        orm_resource.find_by_sql([query, property, "[{\"id\": \"#{obj.id}\"}]"])
      end

      def query
        <<-SQL
        SELECT * FROM orm_resources WHERE
        metadata->? @> ?
      SQL
      end

      def orm_resource
        ::Valkyrie::Persistence::Postgres::ORM::Resource
      end

      def resource_factory
        ::Valkyrie::Persistence::Postgres::ResourceFactory
      end
  end
end
