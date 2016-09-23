# frozen_string_literal: true
module Valkyrie
  module ActiveModel
    def has_attribute?(name)
      respond_to?(name)
    end

    def column_for_attribute(name)
      name
    end

    def persisted?
      to_param.present?
    end

    def to_key
      [id]
    end

    def to_param
      id
    end

    def [](key)
      send(key) if respond_to?(key)
    end
  end
end
