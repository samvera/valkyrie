# frozen_string_literal: true
require 'reform/form/active_model/validations'
require 'reform/form/active_model/model_reflections'
Reform::Form.class_eval do
  include Reform::Form::ActiveModel::Validations
  include Reform::Form::ActiveModel::ModelReflections
end
