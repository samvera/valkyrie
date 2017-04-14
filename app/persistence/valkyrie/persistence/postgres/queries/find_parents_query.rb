# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindParentsQuery
    attr_reader :obj
    def initialize(obj)
      @obj = obj
    end

    def run
      relation.lazy.map do |orm_object|
        resource_factory.to_model(orm_object)
      end
    end

    private

      def relation
        orm_model.find_by_sql([query, "[{\"id\": \"#{obj.id}\"}]"])
      end

      def query
        <<-SQL
        SELECT * FROM orm_resources WHERE
        metadata->'member_ids' @> ?
      SQL
      end

      def orm_model
        ::Valkyrie::Persistence::Postgres::ORM::Resource
      end

      def resource_factory
        ::Valkyrie::Persistence::Postgres::ResourceFactory
      end
  end
end
