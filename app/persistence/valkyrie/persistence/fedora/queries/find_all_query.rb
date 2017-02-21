# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Queries
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
        Valkyrie::Persistence::Fedora::ORM::Resource
      end

      def resource_factory
        ::ResourceFactory.new(adapter: ::Valkyrie::Persistence::Fedora)
      end
  end
end
