# frozen_string_literal: true
##
# These patches are necessary for the postgres adapter to build JSON-LD versions
# of RDF objects when `to_json` is called on them - that way they're stored in
# the database as a standard format.
module RDF
  class Literal
    def as_json(*_args)
      ::JSON::LD::API.fromRdf([RDF::Statement.new(RDF::URI(""), RDF::URI(""), self)])[0][""][0]
    end
  end

  class URI
    def as_json(*_args)
      ::JSON::LD::API.fromRdf([RDF::Statement.new(RDF::URI(""), RDF::URI(""), self)])[0][""][0]
    end
  end

  # Value needs to respond to all possible arguments of to_s, and the upstream
  # doesn't. Remove this when https://github.com/ruby-rdf/rdf/pull/444 is fixed.
  module Value
    def start_with?(*args)
      to_s.start_with?(*args.map(&:to_s))
    end
  end
end
