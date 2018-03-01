# frozen_string_literal: true
require 'valkyrie/persistence/postgres/orm/resource'
module Valkyrie::Persistence::Postgres
  # Namespace for ActiveRecord access in Postgres adapter.
  module ORM
    def self.table_name_prefix
      'orm_'
    end
  end
end
