# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindAllQuery
    attr_reader :obj
    def initialize; end

    def run
      relation.lazy.map do |orm_object|
        ::Valkyrie::Persistence::Postgres::ResourceFactory.from_orm(orm_object)
      end
    end

    private

    def relation
      orm_model.all
    end

    def orm_model
      Valkyrie::Persistence::Postgres::ORM::Resource
    end
  end
end
