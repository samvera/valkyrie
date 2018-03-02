# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  # Composite object to make multiple custom indexers act like a single one, so
  # that upstream code doesn't have to know how to iterate over indexers.
  #
  # @see https://en.wikipedia.org/wiki/Composite_pattern
  class CompositeIndexer
    attr_reader :indexers
    def initialize(*indexers)
      @indexers = indexers
    end

    def new(resource:)
      Instance.new(indexers, resource: resource)
    end

    class Instance
      attr_reader :indexers, :resource
      def initialize(indexers, resource:)
        @resource = resource
        @indexers = indexers.map { |i| i.new(resource: resource) }
      end

      def to_solr
        indexers.map(&:to_solr).inject({}, &:merge)
      end
    end
  end
end
