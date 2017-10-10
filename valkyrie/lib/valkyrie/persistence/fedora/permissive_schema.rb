# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class PermissiveSchema
    attr_reader :schema
    def initialize(schema = {})
      @schema = schema
    end

    def predicate_for(resource:, property:)
      schema.fetch(property, ::RDF::URI("http://example.com/predicate/#{property}"))
    end
  end
end
