# frozen_string_literal: true
module ORM
  class Book < ApplicationRecord
    serialize :metadata, HashSerializer
    store_accessor :metadata, *(::Book.attribute_set.map(&:name) - [:id])
  end
end
