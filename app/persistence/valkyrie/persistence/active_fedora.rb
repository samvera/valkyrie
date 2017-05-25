# frozen_string_literal: true
module Valkyrie::Persistence
  module ActiveFedora
    def persister
      Valkyrie::Persistence::ActiveFedora::Persister
    end

    def query_service
      Valkyrie::Persistence::ActiveFedora::QueryService
    end

    module_function :persister, :query_service
  end
end
