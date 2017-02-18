
# frozen_string_literal: true
module Valkyrie::Persistence::Postgres::Queries
  class FindByIdQuery
    attr_reader :id
    def initialize(id)
      @id = id
    end

    def run
      ::ResourceFactory.from_orm(relation)
    rescue ActiveRecord::RecordNotFound
      raise Persister::ObjectNotFoundError
    end

    private

      def relation
        orm_model.find(id)
      end

      def orm_model
        ::Valkyrie::Persistence::Postgres::ORM::Resource
      end

      def mapper
        ORMToObjectMapper
      end
  end
end
