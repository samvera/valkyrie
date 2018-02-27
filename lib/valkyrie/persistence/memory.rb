# frozen_string_literal: true
#
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata in memory
  module Memory
    require 'valkyrie/persistence/memory/metadata_adapter'
    require 'valkyrie/persistence/memory/persister'
    require 'valkyrie/persistence/memory/query_service'
  end
end
