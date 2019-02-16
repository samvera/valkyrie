# frozen_string_literal: true
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata into Fedora
  module Fedora
    # Deprecation to allow us to make pg an optional dependency
    path = Bundler.definition.gemfiles.first
    matches = File.readlines(path).select { |l| l =~ /gem ['"]ldp\b/ }
    if matches.empty?
      warn "[DEPRECATION] ldp will not be included as a dependency in Valkyrie's gemspec as of the next major release. Please add the gem directly to your Gemfile if you use a fedora adapter."
    end
    require 'active_triples'
    require 'active_fedora'
    require 'valkyrie/persistence/fedora/permissive_schema'
    require 'valkyrie/persistence/fedora/metadata_adapter'
    require 'valkyrie/persistence/fedora/persister'
    require 'valkyrie/persistence/fedora/query_service'
    require 'valkyrie/persistence/fedora/ordered_list'
    require 'valkyrie/persistence/fedora/ordered_reader'
    require 'valkyrie/persistence/fedora/list_node'
  end
end
