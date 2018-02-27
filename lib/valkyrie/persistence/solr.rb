# frozen_string_literal: true
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata into Solr
  module Solr
    require 'valkyrie/persistence/solr/metadata_adapter'
    require 'valkyrie/persistence/solr/composite_indexer'
  end
end
