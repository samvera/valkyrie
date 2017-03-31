# frozen_string_literal: true
module Penguin::Persistence::Fedora::Queries
  class FindByIdQuery
    attr_reader :id
    def initialize(id)
      @id = id
    end

    def run
      ::ResourceFactory.new(adapter: ::Penguin::Persistence::Fedora).to_model(relation)
    rescue ActiveFedora::ObjectNotFoundError, ::Ldp::Gone
      raise ::Persister::ObjectNotFoundError
    end

    private

      def relation
        orm_model.find(id)
      end

      def orm_model
        ::Penguin::Persistence::Fedora::ORM::Resource
      end
  end
end
