# frozen_string_literal: true
class CollectionDecorator < ApplicationDecorator
  delegate_all

  def title
    Array.wrap(super).first
  end
end
