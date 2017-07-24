# frozen_string_literal: true
module Valkyrie::Persistence::ActiveFedora::Queries
  class FindParentsQuery
    attr_reader :obj
    delegate :id, to: :obj
    def initialize(obj)
      @obj = obj
    end

    def run
      resource_factory.from_resource(obj).ordered_by.map do |parent|
        resource_factory.to_resource(parent)
      end
    end

    def resource_factory
      ::Valkyrie::Persistence::ActiveFedora::ResourceFactory
    end
  end
end
