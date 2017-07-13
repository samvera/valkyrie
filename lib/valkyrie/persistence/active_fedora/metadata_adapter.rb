# frozen_string_literal: true
module Valkyrie::Persistence
  module ActiveFedora
    class MetadataAdapter
      # @return [Class] {Valkyrie::Persistence::ActiveFedora::Persister}
      def persister
        Valkyrie::Persistence::ActiveFedora::Persister
      end

      # @return [Class] {Valkyrie::Persistence::ActiveFedora::QueryService}
      def query_service
        Valkyrie::Persistence::ActiveFedora::QueryService
      end
    end
  end
end
