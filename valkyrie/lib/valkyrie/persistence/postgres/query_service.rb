# frozen_string_literal: true
require 'valkyrie/persistence/postgres/queries'
module Valkyrie::Persistence::Postgres
  class QueryService
    class << self
      # (see Valkyrie::Persistence::Memory::QueryService#find_all)
      def find_all
        Valkyrie::Persistence::Postgres::Queries::FindAllQuery.new.run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_all_of_model)
      def find_all_of_model(model:)
        Valkyrie::Persistence::Postgres::Queries::FindAllQuery.new(model: model).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_by)
      def find_by(id:)
        Valkyrie::Persistence::Postgres::Queries::FindByIdQuery.new(id).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_members)
      def find_members(model:)
        Valkyrie::Persistence::Postgres::Queries::FindMembersQuery.new(model).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_parents)
      def find_parents(model:)
        find_inverse_references_by(model: model, property: :member_ids)
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_references_by)
      def find_references_by(model:, property:)
        Valkyrie::Persistence::Postgres::Queries::FindReferencesQuery.new(model, property).run
      end

      # (see Valkyrie::Persistence::Memory::QueryService#find_inverse_references_by)
      def find_inverse_references_by(model:, property:)
        Valkyrie::Persistence::Postgres::Queries::FindInverseReferencesQuery.new(model, property).run
      end
    end
  end
end
