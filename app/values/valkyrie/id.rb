# frozen_string_literal: true
module Valkyrie
  class ID
    # Dry::Types.register_class(self)
    class Attribute < Virtus::Attribute
      def coerce(value)
        return value if value.nil?
        Valkyrie::ID.new(value.to_s)
      end
    end

    attr_reader :id
    delegate :empty?, to: :id
    def initialize(id)
      @id = id
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
      ::RDF::URI(ActiveFedora::Base.id_to_uri(id))
    end

    protected

      def state
        [@id]
      end
  end
end
