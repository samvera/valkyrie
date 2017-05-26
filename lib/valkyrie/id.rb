# frozen_string_literal: true
module Valkyrie
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

    def to_uri
      return RDF::Literal.new(id.to_s, datatype: RDF::URI("http://example.com/valkyrie_id")) if id.to_s.include?("://")
      ::RDF::URI(ActiveFedora::Base.id_to_uri(id))
    end

    protected

      def state
        [@id]
      end
  end
end
