# frozen_string_literal: true
#
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata into Postgres
  module Postgres
    require 'valkyrie/persistence/postgres/metadata_adapter'
  end
end
