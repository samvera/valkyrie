# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindReferencesQuery
    attr_reader :obj, :property
    def initialize(obj, property)
      @obj = obj
      @property = property
    end

    def run
      return [] if obj.id.blank?
      relation.lazy.map do |orm_object|
        resource_factory.to_model(orm_object)
      end
    end

    private

      def relation
        orm_model.find_by_sql([query, property, obj.id.to_s])
      end

      def query
        <<-SQL
        SELECT member.* FROM orm_resources a,
        jsonb_array_elements(a.metadata->?) AS b(member)
        JOIN orm_resources member ON (b.member->>'id')::uuid = member.id WHERE a.id = ?
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
