# frozen_string_literal: true
module Valkyrie
  module ActiveModel
    def self.included(base)
      base.extend ClassMethods
    end

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

    module ClassMethods
      def fields
        ::Book.attribute_set.map(&:name)
      end
    end
  end
end
