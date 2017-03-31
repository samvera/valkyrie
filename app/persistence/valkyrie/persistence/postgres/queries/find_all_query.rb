# frozen_string_literal: true
module Penguin::Persistence::Postgres::Queries
  class FindAllQuery
    attr_reader :obj
    def initialize; end

    def run
      relation.lazy.map do |orm_object|
        ::Penguin::Persistence::Postgres::ResourceFactory.to_model(orm_object)
      end
    end

    private

      def relation
        orm_model.all
      end

      def orm_model
        Penguin::Persistence::Postgres::ORM::Resource
      end
  end
end
