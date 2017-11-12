# frozen_string_literal: true
module Valkyrie::Persistence
  module Redis
    require 'valkyrie/persistence/redis/metadata_adapter'
    require 'valkyrie/persistence/redis/persister'
    require 'valkyrie/persistence/redis/query_service'
  end
end
