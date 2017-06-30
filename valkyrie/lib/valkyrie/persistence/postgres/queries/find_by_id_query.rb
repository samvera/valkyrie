# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindByIdQuery
    attr_reader :id
    def initialize(id)
      @id = id.to_s
    end

    def run
      ::Valkyrie::Persistence::Postgres::ResourceFactory.to_model(relation)
    rescue ActiveRecord::RecordNotFound
      raise Valkyrie::Persistence::ObjectNotFoundError
    end

    private

      def relation
        orm_model.find(id)
      end

      def orm_model
        ::Valkyrie::Persistence::Postgres::ORM::Resource
      end
  end
end
