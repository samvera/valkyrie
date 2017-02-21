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

      if singleton_class?
        class_eval do
          remove_possible_method(:fields)
          define_method(:fields) do
            if instance_variable_defined? "@fields"
              instance_variable_get "@fields"
            else
              singleton_class.send :fields
            end
          end
        end
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
