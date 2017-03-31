# frozen_string_literal: true
module Penguin::Persistence::Fedora::Queries
  class FindAllQuery
    attr_reader :obj
    def initialize; end

    def run
      relation.lazy.map do |orm_object|
        resource_factory.to_model(orm_object)
      end
    end

    private

      def relation
        orm_model.all
      end

      def orm_model
        Penguin::Persistence::Fedora::ORM::Resource
      end

      def resource_factory
        ::ResourceFactory.new(adapter: ::Penguin::Persistence::Fedora)
      end
  end
end
