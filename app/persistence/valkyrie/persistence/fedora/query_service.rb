# frozen_string_literal: true
module Penguin::Persistence::Fedora
  class QueryService
    class << self
      def find_all
        Penguin::Persistence::Fedora::Queries::FindAllQuery.new.run
      end

      def find_by_id(id)
        Penguin::Persistence::Fedora::Queries::FindByIdQuery.new(id).run
      end

      def find_members(book)
        Penguin::Persistence::Fedora::Queries::FindMembersQuery.new(book).run
      end
    end
  end
end
