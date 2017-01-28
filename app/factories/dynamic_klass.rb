# frozen_string_literal: true
class DynamicKlass
  def self.new(attributes)
    attributes["model_type"].constantize.new(attributes)
  end
end
