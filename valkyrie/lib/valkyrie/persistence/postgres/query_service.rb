# frozen_string_literal: true
require 'valkyrie/persistence/postgres/queries'
module Valkyrie::Persistence::Postgres
  class QueryService
    class << self
      # (see Valkyrie::Persistence::Memory::QueryService#find_all)
      def find_all
        Valkyrie::Persistence::Postgres::Queries::FindAllQuery.new.run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_all_of_resource)
      def find_all_of_resource(resource:)
        Valkyrie::Persistence::Postgres::Queries::FindAllQuery.new(resource: resource).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_by)
      def find_by(id:)
        Valkyrie::Persistence::Postgres::Queries::FindByIdQuery.new(id).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_members)
      def find_members(resource:)
        Valkyrie::Persistence::Postgres::Queries::FindMembersQuery.new(resource).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_parents)
      def find_parents(resource:)
        find_inverse_references_by(resource: resource, property: :member_ids)
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_references_by)
      def find_references_by(resource:, property:)
        Valkyrie::Persistence::Postgres::Queries::FindReferencesQuery.new(resource, property).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_inverse_references_by)
      def find_inverse_references_by(resource:, property:)
        Valkyrie::Persistence::Postgres::Queries::FindInverseReferencesQuery.new(resource, property).run
      end
    end
  end
end
