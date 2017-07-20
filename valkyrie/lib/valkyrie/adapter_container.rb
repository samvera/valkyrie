# frozen_string_literal: true
module Valkyrie
  class AdapterContainer
    # Wraps up an individual persister, query service and file node persister to
    # conform to the adapter interface. Useful for decorated persisters.
    attr_reader :persister, :query_service, :file_node_persister
    def initialize(persister:, query_service:, file_node_persister:)
      @persister = persister
      @query_service = query_service
      @file_node_persister = file_node_persister
    end
  end
end
