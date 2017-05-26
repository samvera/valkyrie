# frozen_string_literal: true
module Valkyrie::Persistence
  module ActiveFedora
    class Adapter
      def self.persister
        Valkyrie::Persistence::ActiveFedora::Persister
      end

      def self.query_service
        Valkyrie::Persistence::ActiveFedora::QueryService
      end
    end
  end
end
