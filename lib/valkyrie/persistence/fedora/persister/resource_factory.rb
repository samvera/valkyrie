# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    # Provides access to generic methods for converting to/from
    # {Valkyrie::Resource} and {LDP::Container::Basic}.
    class ResourceFactory
      require 'valkyrie/persistence/fedora/persister/model_converter'
      require 'valkyrie/persistence/fedora/persister/orm_converter'
      attr_reader :adapter
      def initialize(adapter:)
        @adapter = adapter
      end

      def from_resource(resource:)
        ModelConverter.new(resource: resource, adapter: adapter).convert
      end

      def to_resource(object:)
        OrmConverter.new(object: object, adapter: adapter).convert
      end
    end
  end
end
