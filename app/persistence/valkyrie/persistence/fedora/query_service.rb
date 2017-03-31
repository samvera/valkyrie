# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class QueryService
    class << self
      def find_all
        Valkyrie::Persistence::Fedora::Queries::FindAllQuery.new.run
      end

      def find_by_id(id:)
        Valkyrie::Persistence::Fedora::Queries::FindByIdQuery.new(id).run
      end

      def find_members(*opts)
        model = opts.fetch(:model) if opts[0].respond_to?(:fetch)
        model = opts[0]
        Valkyrie::Persistence::Fedora::Queries::FindMembersQuery.new(model).run
      end
    end
  end
end
