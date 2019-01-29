# frozen_string_literal: true
module Valkyrie
  # A simple ID class to keep IDs distinguished from strings
  # In order for an object to be queryable via joins, it needs
  # to be added as a reference via a Valkyrie::ID rather than just a string ID.
  class ID
    attr_reader :id
    delegate :empty?, to: :id
    def initialize(id)
      @id = id.to_s
    end

    def to_s
      id
    end

    delegate :hash, to: :state

    def eql?(other)
      other.class == self.class && other.state == state
    end
    alias == eql?

    # @deprecated Please use {.uri_for} instead
    def to_uri
      return RDF::Literal.new(id.to_s, datatype: RDF::URI("http://example.com/valkyrie_id")) if id.to_s.include?("://")
      warn "[DEPRECATION] `to_uri` is deprecated and will be removed in the next major release. " \
           "Called from #{Gem.location_of_caller.join(':')}"
      ::RDF::URI(ActiveFedora::Base.id_to_uri(id))
    end

    protected

      def state
        [@id]
      end
  end
end
