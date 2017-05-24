# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  class DynamicKlass
    def self.new(attributes)
      attributes[:model_type].constantize.new(attributes)
    end
  end
end
