# frozen_string_literal: true

module Valkyrie::Persistence
  # Allows for implementors to register and use custom queries on a
  #  per persister basis
  #
  # @example Custom Query Class
  #
  #     # Snippet from custom query class see: https://github.com/pulibrary/figgy/blob/d0b1305a1564c2aa4e7d6c1e99f0c2a88ed673f4/app/queries/find_by_string_property.rb
  #     class FindByStringProperty
  #       def self.queries
  #         [:find_by_string_property]
  #       end
  #
  #       ...
  #
  #       def initialize(query_service:)
  #         @query_service = query_service
  #       end
  #       ...
  #
  #       def find_by_string_property(property:, value:)
  #         internal_array = "{\"#{property}\": [\"#{value}\"]}"
  #         run_query(query, internal_array)
  #       end
  #       ...
  #     end
  #
  # @example Registration
  #
  #   # in config/initializers/valkyrie.rb
  #   [FindByStringProperty].each do |query_handler|
  #     Valkyrie.config.metadata_adapter.query_service.custom_queries.register_query_handler(query_handler)
  #   end
  #
  # @see lib/valkyrie/persistence/solr/query_service.rb for use of this class
  #
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
      handler_class =
        find_query_handler(meth_name) ||
        raise(NoMethodError, "Custom query #{meth_name} is not registered. The registered queries are: #{queries}")

      query_handler = handler_class.new(query_service: query_service)
      return super unless query_handler
      query_handler.__send__(meth_name, *args, &block)
    end

    def find_query_handler(method)
      query_handlers.find { |x| x.queries.include?(method) }
    end

    def respond_to_missing?(meth_name, _args)
      find_query_handler(meth_name).present?
    end

    private

    def queries
      query_handlers.map(&:queries).flatten
    end
  end
end
