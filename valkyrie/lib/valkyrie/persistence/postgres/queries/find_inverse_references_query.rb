# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindInverseReferencesQuery
    delegate :orm_class, to: :resource_factory
    attr_reader :obj, :property, :resource_factory
    def initialize(obj, property, resource_factory:)
      @obj = obj
      @property = property
      @resource_factory = resource_factory
    end

    def run
      relation.lazy.map do |orm_object|
        resource_factory.to_resource(orm_object)
      end
    end

    private

      def relation
        orm_class.find_by_sql([query, property, "[{\"id\": \"#{obj.id}\"}]"])
      end

      def query
        <<-SQL
        SELECT * FROM orm_resources WHERE
        metadata->? @> ?
      SQL
      end
  end
end
