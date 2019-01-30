# frozen_string_literal: true
begin
  gem 'pg'
rescue Gem::LoadError => e
  raise Gem::LoadError,
        "You are using the Postgres adapter without installing the #{e.name} gem.  "\
        "Add `gem '#{e.name}'` to your Gemfile."
end
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata into Postgres
  module Postgres
    require 'valkyrie/persistence/postgres/metadata_adapter'
  end
end
