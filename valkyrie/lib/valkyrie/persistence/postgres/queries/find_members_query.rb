# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindMembersQuery
    attr_reader :obj, :resource_factory
    delegate :orm_class, to: :resource_factory
    def initialize(obj, resource_factory:)
      @obj = obj
      @resource_factory = resource_factory
    end

    def run
      return [] if obj.id.blank?
      relation.lazy.map do |orm_object|
        resource_factory.to_resource(object: orm_object)
      end
    end

    private

      def relation
        orm_class.find_by_sql([query, obj.id.to_s])
      end

      def query
        <<-SQL
        SELECT member.* FROM orm_resources a,
        jsonb_array_elements(a.metadata->'member_ids') WITH ORDINALITY AS b(member, member_pos)
        JOIN orm_resources member ON (b.member->>'id')::uuid = member.id WHERE a.id = ?
        ORDER BY b.member_pos
      SQL
      end
  end
end
