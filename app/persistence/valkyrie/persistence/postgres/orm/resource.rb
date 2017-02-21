# frozen_string_literal: true
module Valkyrie::Persistence::Postgres
  module ORM
    class Resource < ActiveRecord::Base
      store_accessor :metadata, *(::Book.attribute_set.map(&:name) - [:id])

      def all_attributes
        attributes.merge(metadata)
      end
    end
  end
end
