# frozen_string_literal: true
module Valkyrie
  module ActiveModel
    def self.included(base)
      base.include(Virtus.model)
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

    def to_model
      self
    end

    def model_name
      ::ActiveModel::Name.new(self.class)
    end

    module ClassMethods
      def fields
        attribute_set.map(&:name)
      end
    end
  end
end
