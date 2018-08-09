# frozen_string_literal: true
module Valkyrie::Persistence::Fedora
  # Represents a node in an ORE List. Used for persisting ordered members into
  # an RDF Graph for Fedora, to keep order maintained.
  class ListNode
    attr_reader :rdf_subject, :graph
    attr_writer :next, :prev
    attr_accessor :target
    attr_writer :next_uri, :prev_uri
    attr_accessor :proxy_in, :proxy_for
    attr_reader :adapter
    def initialize(node_cache, rdf_subject, adapter, graph = RDF::Repository.new)
      @rdf_subject = rdf_subject
      @graph = graph
      @node_cache = node_cache
      @adapter = adapter
      Builder.new(rdf_subject, graph).populate(self)
    end

    # Returns the next proxy or a tail sentinel.
    # @return [RDF::URI]
    def next
      @next ||=
        if next_uri
          node_cache.fetch(next_uri) do
            node = self.class.new(node_cache, next_uri, adapter, graph)
            node.prev = self
            node
          end
        end
    end

    # Returns the previous proxy or a head sentinel.
    # @return [RDF::URI]
    def prev
      @prev ||= node_cache.fetch(prev_uri) if prev_uri
    end

    # Graph representation of node.
    # @return [Valkyrie::Persistence::Fedora::ListNode::Resource]
    def to_graph
      return RDF::Graph.new if target_id.blank?
      g = Resource.new(rdf_subject)
      g.proxy_for = target_uri
      g.proxy_in = proxy_in.try(:uri)
      g.next = self.next.try(:rdf_subject)
      g.prev = prev.try(:rdf_subject)
      g
    end

    def target_uri
      adapter.id_to_uri(target_id.to_s)
    end

    def target_id
      adapter.uri_to_id(proxy_for)
    end

    private

      attr_reader :next_uri, :prev_uri, :node_cache

      class Builder
        attr_reader :uri, :graph
        def initialize(uri, graph)
          @uri = uri
          @graph = graph
        end

        def populate(instance)
          instance.proxy_for = resource.proxy_for.first
          instance.proxy_in = resource.proxy_in.first
          instance.next_uri = resource.next.first
          instance.prev_uri = resource.prev.first
        end

        private

          def resource
            @resource ||= Resource.new(uri, data: graph)
          end
      end

      class Resource < ActiveTriples::Resource
        property :proxy_for, predicate: ::RDF::Vocab::ORE.proxyFor, cast: false
        property :proxy_in, predicate: ::RDF::Vocab::ORE.proxyIn, cast: false
        property :next, predicate: ::RDF::Vocab::IANA.next, cast: false
        property :prev, predicate: ::RDF::Vocab::IANA.prev, cast: false
      end
  end
end
