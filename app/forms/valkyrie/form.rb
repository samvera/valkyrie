# frozen_string_literal: true
module Valkyrie
  class Form < Reform::Form
    class_attribute :fields
    self.fields = []
    def self.fields=(fields)
      singleton_class.class_eval do
        remove_possible_method(:fields)
        define_method(:fields) { fields }
      end

      fields.each do |field|
        property field
      end
      fields
    end

    delegate :attributes, to: :model

    def resource_class
      model.class
    end
  end
end
