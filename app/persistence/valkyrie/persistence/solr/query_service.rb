# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class QueryService
    class << self
      def find_by_id(id)
        Valkyrie::Persistence::Solr::Queries::FindByIdQuery.new(id).run
      end
    end
  end
end
