# frozen_string_literal: true
module Valkyrie::Persistence
  module Fedora
    def persister
      Valkyrie::Persistence::Fedora::Persister
    end

    def query_service
      Valkyrie::Persistence::Fedora::QueryService
    end

    module_function :persister, :query_service
  end
end
