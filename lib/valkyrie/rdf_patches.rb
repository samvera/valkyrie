# frozen_string_literal: true
##
# These patches are necessary for the postgres adapter to build JSON-LD versions
# of RDF objects when `to_json` is called on them - that way they're stored in
# the database as a standard format.
module RDFPatches
  refine RDF::Literal do
    def as_json(*_args)
      ::JSON::LD::API.fromRdf([RDF::Statement.new(RDF::URI(""), RDF::URI(""), self)])[0][""][0]
    end
  end

  refine RDF::URI do
    def as_json(*_args)
      ::JSON::LD::API.fromRdf([RDF::Statement.new(RDF::URI(""), RDF::URI(""), self)])[0][""][0]
    end
  end
end
