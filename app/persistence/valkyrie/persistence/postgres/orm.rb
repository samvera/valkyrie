# frozen_string_literal: true
module Penguin::Persistence::Postgres
  module ORM
    def self.table_name_prefix
      'orm_'
    end
  end
end
