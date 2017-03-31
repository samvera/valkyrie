# frozen_string_literal: true
module Penguin
  def config
    Config.new(
      YAML.load(ERB.new(File.read("#{Rails.root}/config/penguin.yml")).result)[Rails.env]
    )
  end

  class Config < OpenStruct
    def adapter
      Penguin::Adapter.find(super.to_sym)
    end
  end

  module_function :config
  module ActiveModel
    def self.included(base)
      base.include Virtus.model
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

    def resource_class
      self.class
    end

    def to_s
      "#{resource_class}: #{id}"
    end

    module ClassMethods
      def fields
        attribute_set.map(&:name)
      end
    end
  end
end
