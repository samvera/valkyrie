# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class QueryService
    class << self
      def find_all
        Valkyrie::Persistence::Postgres::Queries::FindAllQuery.new.run
      end

      def find_by_id(old_id = nil, id: nil)
        id ||= old_id
        Valkyrie::Persistence::Postgres::Queries::FindByIdQuery.new(id).run
      end

      def find_members(book)
        Valkyrie::Persistence::Postgres::Queries::FindMembersQuery.new(book).run
      end
    end
  end
end
