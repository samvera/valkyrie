# frozen_string_literal: true
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata into Solr
  module Solr
    # Deprecation to allow us to make rsolr an optional dependency
    path = Bundler.definition.gemfiles.first
    matches = File.readlines(path).select { |l| l =~ /gem ['"]rsolr\b/ }
    if matches.empty?
      warn "[DEPRECATION] rsolr will not be included as a dependency in Valkyrie's gemspec as of the next major release. Please add the gem directly to your Gemfile if you use a solr adapter."
    end
    require 'valkyrie/persistence/postgres/metadata_adapter'
    require 'valkyrie/persistence/solr/metadata_adapter'
    require 'valkyrie/persistence/solr/composite_indexer'
  end
end
