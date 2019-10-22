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
      (other.class == self.class && other.state == state) ||
      (other.to_s == self.to_s)
    end
    alias == eql?

    protected

      def state
        [@id]
      end
  end
end
