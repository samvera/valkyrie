# frozen_string_literal: true
module Penguin::Persistence::Postgres::Queries
  class FindByIdQuery
    attr_reader :id
    def initialize(id)
      @id = id
    end

    def run
      ::ResourceFactory.new(adapter: ::Penguin::Persistence::Postgres).to_model(relation)
    rescue ActiveRecord::RecordNotFound
      raise ::Persister::ObjectNotFoundError
    end

    private

      def relation
        orm_model.find(id)
      end

      def orm_model
        ::Penguin::Persistence::Postgres::ORM::Resource
      end
  end
end
