# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Queries
  class FindParentsQuery
    attr_reader :obj
    delegate :id, to: :obj
    def initialize(obj)
      @obj = obj
    end

    def run
      resource_factory.from_model(obj).ordered_by.map do |parent|
        resource_factory.to_model(parent)
      end
    end

    def resource_factory
      ::Valkyrie::Persistence::Fedora::ResourceFactory
    end
  end
end
