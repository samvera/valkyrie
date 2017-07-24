# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class DynamicKlass
    # @param attributes [Hash]
    # @option attributes [String] :internal_resource The {Valkyrie::Resource} class to
    #   create.
    # @return [Valkyrie::Resource] The resource with the class identified by the
    #   attributes' `internal_resource` key.
    def self.new(attributes)
      attributes[:internal_resource].constantize.new(attributes)
    end
  end
end
