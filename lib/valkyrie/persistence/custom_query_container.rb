# frozen_string_literal: true
module Valkyrie::Persistence
  class CustomQueryContainer
    attr_reader :query_service, :query_handlers
    def initialize(query_service:)
      @query_service = query_service
      @query_handlers = []
    end

    def register_query_handler(query_handler)
      @query_handlers << query_handler
    end

    def method_missing(meth_name, *args, &block)
      query_handler = find_query_handler(meth_name).new(query_service: query_service)
      return super unless query_handler
      query_handler.__send__(meth_name, *args, &block)
    end

    def find_query_handler(method)
      query_handlers.find { |x| x.queries.include?(method) }
    end

    def respond_to_missing?(meth_name, _args)
      find_query_handler(meth_name).present?
    end
  end
end
