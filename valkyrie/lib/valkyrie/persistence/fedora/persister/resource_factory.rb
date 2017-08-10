# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  class Persister
    class ResourceFactory
      require 'valkyrie/persistence/fedora/persister/model_converter'
      require 'valkyrie/persistence/fedora/persister/orm_converter'
      def self.from_resource(resource:, adapter:)
        ModelConverter.new(resource: resource, adapter: adapter).convert
      end

      def self.to_resource(object:, adapter:)
        OrmConverter.new(object: object, adapter: adapter).convert
      end
    end
  end
end
