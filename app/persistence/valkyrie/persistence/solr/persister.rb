# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  class Persister
    attr_reader :adapter
    delegate :connection, to: :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    def save(model)
      Valkyrie::Persistence::Solr::Repository.new(model: model, connection: connection).persist
    end
  end
end
