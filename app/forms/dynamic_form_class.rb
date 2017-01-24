# frozen_string_literal: true
class DynamicFormClass
  attr_reader :model_param
  def initialize(model_param)
    @model_param = model_param
  end

  def new(obj, *args)
    if model_param
      "#{model_param}Form".constantize.new(obj, *args)
    else
      "#{obj.class}Form".constantize.new(obj, *args)
    end
  end
end
