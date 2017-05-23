# frozen_string_literal: true
module Valkyrie
  class Model < Dry::Struct
    include Draper::Decoratable
    constructor_type :schema
    def self.fields
      schema.keys
    end

    def self.attribute(name, type = Valkyrie::Types::Set.optional)
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", self.class.schema[name].call(value))
      end
      super
    end

    def attributes
      to_h
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

    def resource_class
      self.class
    end

    def to_s
      "#{resource_class}: #{id}"
    end
  end
end
