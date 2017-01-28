# frozen_string_literal: true
class PersistableForm < SimpleDelegator
  def attributes
    __getobj__.model.attributes
  end

  def class
    __getobj__.model.class
  end
end
