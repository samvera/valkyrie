# frozen_string_literal: true
module Valkyrie
  module Persistence
    require 'valkyrie/persistence/memory'
    require 'valkyrie/persistence/postgres'
    require 'valkyrie/persistence/solr'
    require 'valkyrie/persistence/composite_persister'
    require 'valkyrie/persistence/buffered_persister'
    class ObjectNotFoundError < StandardError
    end
  end
end
