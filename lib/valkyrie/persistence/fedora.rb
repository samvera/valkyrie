# frozen_string_literal: true
module Valkyrie::Persistence
  module Fedora
    require 'valkyrie/persistence/fedora/permissive_schema'
    require 'valkyrie/persistence/fedora/metadata_adapter'
    require 'valkyrie/persistence/fedora/persister'
    require 'valkyrie/persistence/fedora/query_service'
    require 'valkyrie/persistence/fedora/ordered_list'
    require 'valkyrie/persistence/fedora/ordered_reader'
    require 'valkyrie/persistence/fedora/list_node'
  end
end
