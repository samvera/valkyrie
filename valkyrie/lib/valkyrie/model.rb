# frozen_string_literal: true
module Valkyrie
  ##
  # The base model class for all Valkyrie metadata objects.
  # @example Define a model
  #   class Book < Valkyrie::Model
  #     attribute :id, Valkyrie::Types::ID.optional
  #     attribute :member_ids, Valkyrie::Types::Array
  #     attribute :author
  #   end
  class Model < Dry::Struct
    include Draper::Decoratable
    constructor_type :schema

    # Overridden to provide default attributes.
    # @note The current theory is that we should use this sparingly.
    def self.inherited(subclass)
      ::Dry::Struct.inherited(subclass)
      subclass.constructor_type :schema
      subclass.attribute :internal_model, Valkyrie::Types::Any.default(subclass.to_s)
      subclass.attribute :created_at, Valkyrie::Types::DateTime.optional
      subclass.attribute :updated_at, Valkyrie::Types::DateTime.optional
    end

    # @return [Array<Symbol>] Array of fields defined for this class.
    def self.fields
      schema.keys
    end

    # Define an attribute.
    # @param name [Symbol]
    # @param type [Dry::Types::Type]
    # @note Overridden from {Dry::Struct} to make the default type
    #   {Valkyrie::Types::Set}
    def self.attribute(name, type = Valkyrie::Types::Set.optional)
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", self.class.schema[name].call(value))
      end
      super
    end

    # @return [Hash] Hash of attributes
    def attributes
      to_h
    end

    # @param name [Symbol] Attribute name
    # @return [Boolean]
    def has_attribute?(name)
      respond_to?(name)
    end

    # @param name [Symbol]
    # @return [Symbol]
    # @note Added for ActiveModel compatibility.
    def column_for_attribute(name)
      name
    end

    # @return [Boolean]
    def persisted?
      to_param.present?
    end

    def to_key
      [id]
    end

    def to_param
      id
    end

    # @note Added for ActiveModel compatibility
    def to_model
      self
    end

    # @return [ActiveModel::Name]
    # @note Added for ActiveModel compatibility.
    def model_name
      ::ActiveModel::Name.new(self.class)
    end

    # @return [String]
    def to_s
      "#{self.class}: #{id}"
    end
  end
end
