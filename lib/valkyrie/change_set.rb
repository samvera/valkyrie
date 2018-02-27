# frozen_string_literal: true
require 'reform/form/coercion'
require 'reform/form/active_model/validations'
module Valkyrie
  ##
  # Standard change set object for Valkyrie.
  # ChangeSets are a way to group together properties that should be applied to
  # an underlying resource. They are often used for powering HTML Forms or
  # storing virtual attributes for special synchronization with a resource.
  # @example Define a change set
  #   class BookChangeSet < Valkyrie::ChangeSet
  #     self.fields = [:title, :author]
  #     validates :title, presence: true
  #     property :title, multiple: false, required: true
  #   end
  class ChangeSet < Reform::Form
    include Reform::Form::ModelReflections
    include Reform::Form::ActiveModel::Validations
    feature Coercion
    class_attribute :fields
    self.fields = []

    property :append_id, virtual: true

    # Set ID of record this one should be appended to.
    # @param append_id [Valkyrie::ID]
    def append_id=(append_id)
      super(Valkyrie::ID.new(append_id))
    end

    # Returns whether or not a given field has multiple values.
    # @param field [Symbol]
    # @return [Boolean]
    def multiple?(field)
      self.class.definitions[field.to_s][:multiple] != false
    end

    # Returns whether or not a given field is required.
    # @param field [Symbol]
    # @return [Boolean]
    def required?(field)
      self.class.definitions[field.to_s][:required] == true
    end

    # Quick setter for fields that should be in a changeset. Defaults to multiple,
    # not required, with an empty array default.
    # @param fields [Array<Symbol>]
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

    # Returns value for a given property.
    # @param key [Symbol]
    def [](key)
      send(key) if respond_to?(key)
    end

    delegate :attributes, to: :resource

    delegate :internal_resource, :created_at, :updated_at, :model_name, to: :resource

    # Prepopulates all fields with defaults defined in the changeset. This is an
    # override of Reform::Form's method to allow for single-valued fields to
    # prepopulate appropriately.
    def prepopulate!(_options = {})
      self.class.definitions.select { |_field, definition| definition[:multiple] == false }.each_key do |field|
        value = Array.wrap(send(field.to_s)).first
        send("#{field}=", value)
      end
      super
      self
    end

    def resource
      model
    end

    def valid?
      errors.clear
      super
    end
  end
end
