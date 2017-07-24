# frozen_string_literal: true
class DynamicChangeSetClass
  attr_reader :resource_param
  def initialize(resource_param = nil)
    @resource_param = resource_param
  end

  def new(obj, *args)
    if resource_param
      "#{resource_param}ChangeSet".constantize.new(obj, *args)
    else
      "#{obj.class}ChangeSet".constantize.new(obj, *args)
    end
  end
end
