# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindReferencesQuery
    delegate :orm_class, to: :resource_factory
    attr_reader :obj, :property, :resource_factory
    def initialize(obj, property, resource_factory:)
      @obj = obj
      @property = property
      @resource_factory = resource_factory
    end

    def run
      return [] if obj.id.blank? || obj[property].blank?
      relation.lazy.map do |orm_object|
        resource_factory.to_resource(object: orm_object)
      end
    end

    private

      def relation
        orm_class.find_by_sql([query, property, obj.id.to_s])
      end

      def query
        <<-SQL
        SELECT member.* FROM orm_resources a,
        jsonb_array_elements(a.metadata->?) AS b(member)
        JOIN orm_resources member ON (b.member->>'id')::uuid = member.id WHERE a.id = ?
      SQL
      end
  end
end
