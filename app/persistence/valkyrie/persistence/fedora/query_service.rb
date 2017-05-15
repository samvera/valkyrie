# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class QueryService
    class << self
      def find_all
        Valkyrie::Persistence::Fedora::Queries::FindAllQuery.new.run
      end

      def find_all_of_model(model:)
        Valkyrie::Persistence::Fedora::Queries::FindAllQuery.new(model: model).run
      end

      def find_by(id:)
        Valkyrie::Persistence::Fedora::Queries::FindByIdQuery.new(id).run
      end

      def find_members(model:)
        Valkyrie::Persistence::Fedora::Queries::FindMembersQuery.new(model).run
      end

      def find_parents(model:)
        Valkyrie::Persistence::Fedora::Queries::FindParentsQuery.new(model).run
      end

      def find_references_by(model:, property:)
        Valkyrie::Persistence::Fedora::Queries::FindReferencesQuery.new(model, property).run
      end
    end
  end
end
