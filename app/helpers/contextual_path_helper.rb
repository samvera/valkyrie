# frozen_string_literal: true
module ContextualPathHelper
  def contextual_path(child, parent)
    ContextualPath.new(child.id, parent.try(:id))
  end
end
