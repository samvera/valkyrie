# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class DynamicKlass
    # @param attributes [Hash]
    # @option attributes [String] :internal_model The {Valkyrie::Model} class to
    #   create.
    # @return [Valkyrie::Model] The model with the class identified by the
    #   attributes' `internal_model` key.
    def self.new(attributes)
      attributes[:internal_model].constantize.new(attributes)
    end
  end
end
