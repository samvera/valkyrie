# frozen_string_literal: true
require 'reform/form/coercion'
module Valkyrie
  class Form < Reform::Form
    feature Coercion
    class_attribute :fields
    self.fields = []

    property :append_id, virtual: true

    def append_id=(append_id)
      super(Valkyrie::ID.new(append_id))
    end

    def multiple?(field)
      self.class.definitions[field.to_s][:multiple] != false
    end

    def required?(field)
      self.class.definitions[field.to_s][:required]
    end

    def self.fields=(fields)
      singleton_class.class_eval do
        remove_possible_method(:fields)
        define_method(:fields) { fields }
      end

      fields.each do |field|
        property field, default: []
      end
      fields
    end

    def [](key)
      send(key) if respond_to?(key)
    end

    delegate :attributes, to: :model

    def resource_class
      model.class
    end

    def prepopulate!(_options = {})
      self.class.definitions.select { |_field, definition| definition[:multiple] == false }.each do |field, _definition|
        value = Array.wrap(send(field.to_s)).first
        send("#{field}=", value)
      end
      self
    end
  end
end
