# frozen_string_literal: true
class SongDecorator < ApplicationDecorator
  delegate_all

  def title
    Array.wrap(super).first
  end
end
