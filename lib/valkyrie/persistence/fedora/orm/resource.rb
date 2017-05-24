# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::ORM
  class Schema < ActiveTriples::Schema
    property :title, predicate: ::RDF::Vocab::DC.title
    property :author, predicate: ::RDF::Vocab::DC.creator
    property :testing, predicate: ::RDF::URI("http://test.com/testing")
    property :a_member_of, predicate: ::RDF::URI("http://test.com/member_of")
    property :viewing_hint, predicate: ::RDF::Vocab::IIIF.viewingHint
    property :viewing_direction, predicate: ::RDF::Vocab::IIIF.viewingDirection
    property :thumbnail_id, predicate: ::RDF::URI("http://test.com/thumbnail_id")
    property :representative_id, predicate: ::RDF::URI("http://test.com/representative_id")
    property :start_canvas, predicate: ::RDF::URI("http://test.com/start_canvas")
    property :internal_model, predicate: ::RDF::URI("http://test.com/internal_model")
    property :file_identifiers, predicate: ::RDF::URI("http://test.com/file_identifiers")
    property :label, predicate: ::RDF::URI("http://test.com/label")
  end
  class Resource < ActiveFedora::Base
    include Hydra::AccessControls::Permissions
    include Hydra::Works::WorkBehavior
    apply_schema Schema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:symbol, :stored_searchable, :facetable])
    )

    def to_solr(doc = {})
      super.merge(
        uri_ssi: uri.to_s
      )
    end
  end
end
