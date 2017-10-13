# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora
  class QueryService
    class << self
      def find_all
        Valkyrie::Persistence::ActiveFedora::Queries::FindAllQuery.new.run
      end

      def find_all_of_model(model:)
        Valkyrie::Persistence::ActiveFedora::Queries::FindAllQuery.new(model: model).run
      end

      def find_by(id:)
        validate_id(id)
        Valkyrie::Persistence::ActiveFedora::Queries::FindByIdQuery.new(id).run
      end

      def find_members(resource:, model: nil)
        Valkyrie::Persistence::ActiveFedora::Queries::FindMembersQuery.new(resource, model).run
      end

      def find_parents(resource:)
        Valkyrie::Persistence::ActiveFedora::Queries::FindParentsQuery.new(resource).run
      end

      def find_references_by(resource:, property:)
        Valkyrie::Persistence::ActiveFedora::Queries::FindReferencesQuery.new(resource, property).run
      end

      def find_inverse_references_by(resource:, property:)
        Valkyrie::Persistence::ActiveFedora::Queries::FindInverseReferencesQuery.new(resource, property).run
      end

      def custom_queries
        @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
      end

      private

        def validate_id(id)
          raise ArgumentError, 'id must be a Valkyrie::ID' unless id.is_a? Valkyrie::ID
        end
    end
  end
end
