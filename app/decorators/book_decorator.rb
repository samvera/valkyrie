# frozen_string_literal: true
class BookDecorator < ApplicationDecorator
  delegate_all

  def title
    Array.wrap(super).first
  end
end
