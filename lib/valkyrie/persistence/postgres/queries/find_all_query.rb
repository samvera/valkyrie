# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindAllQuery
    attr_reader :model
    def initialize(model: nil)
      @model = model
    end

    def run
      relation.lazy.map do |orm_object|
        ::Valkyrie::Persistence::Postgres::ResourceFactory.to_model(orm_object)
      end
    end

    private

      def relation
        if !model
          orm_model.all
        else
          orm_model.where(model_type: model.to_s)
        end
      end

      def orm_model
        Valkyrie::Persistence::Postgres::ORM::Resource
      end
  end
end
