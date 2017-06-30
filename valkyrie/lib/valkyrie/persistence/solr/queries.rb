# frozen_string_literal: true
module Valkyrie::Persistence::Solr
  module Queries
    require 'valkyrie/persistence/solr/queries/default_paginator'
    require 'valkyrie/persistence/solr/queries/find_all_query'
    require 'valkyrie/persistence/solr/queries/find_by_id_query'
    require 'valkyrie/persistence/solr/queries/find_inverse_references_query'
    require 'valkyrie/persistence/solr/queries/find_members_query'
    require 'valkyrie/persistence/solr/queries/find_references_query'
  end
end
