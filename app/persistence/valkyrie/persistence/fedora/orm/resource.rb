# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::ORM
  class Schema < ActiveTriples::Schema
    property :title, predicate: ::RDF::Vocab::DC.title
    property :author, predicate: ::RDF::Vocab::DC.creator
    property :testing, predicate: ::RDF::URI("http://test.com/testing")
    property :viewing_hint, predicate: ::RDF::Vocab::IIIF.viewingHint
    property :viewing_direction, predicate: ::RDF::Vocab::IIIF.viewingDirection
    property :thumbnail_id, predicate: ::RDF::URI("http://test.com/thumbnail_id")
    property :representative_id, predicate: ::RDF::URI("http://test.com/representative_id")
    property :start_canvas, predicate: ::RDF::URI("http://test.com/start_canvas")
    property :internal_model, predicate: ::RDF::URI("http://test.com/internal_model")
  end
  class Resource < ActiveFedora::Base
    include Hydra::Works::WorkBehavior
    apply_schema Schema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:symbol, :stored_searchable, :facetable])
    )
  end
end
