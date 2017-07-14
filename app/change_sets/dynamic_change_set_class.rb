# frozen_string_literal: true
class DynamicChangeSetClass
  attr_reader :model_param
  def initialize(model_param = nil)
    @model_param = model_param
  end

  def new(obj, *args)
    if model_param
      "#{model_param}ChangeSet".constantize.new(obj, *args)
    else
      "#{obj.class}ChangeSet".constantize.new(obj, *args)
    end
  end
end
