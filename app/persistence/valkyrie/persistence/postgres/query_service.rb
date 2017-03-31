# frozen_string_literal: true
module Penguin::Persistence::Postgres
  class QueryService
    class << self
      def find_all
        Penguin::Persistence::Postgres::Queries::FindAllQuery.new.run
      end

      def find_by_id(id)
        Penguin::Persistence::Postgres::Queries::FindByIdQuery.new(id).run
      end

      def find_members(book)
        Penguin::Persistence::Postgres::Queries::FindMembersQuery.new(book).run
      end
    end
  end
end
